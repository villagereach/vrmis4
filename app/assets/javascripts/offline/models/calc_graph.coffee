class Models.CalcGraph
  constructor: (options) ->
    _.extend @, Backbone.Events

    @_logger = window.console
    @_refs = {}
    @_memoized = {}
    @afterCalculate = options.afterCalculate
    @methods = _.extend @.defaultMethods, options.methods

    @register(def) for def in options.definitions

  reset: ->
    @_memoized = {}

  walk: (definition, callback) ->
    definitions = [definition]
    while definition = definitions.shift()
      values = definition.values || [definition.value]
      for value in values
        # skip objects that don't look like a definition
        if _.isObject(value) && (value.ref || value.method)
          definitions.push(value)
      callback(definition)
    @

  register: (definition) ->
    @walk definition, (def) =>
      return if def.ref # don't register references to other definitions

      refId = def.name
      refId ?= (def.name = @genRefId())
      if @_refs[refId]
        @_logger.warn "definition already registered with name #{refId}"

      @_refs[refId] = def
      @on("calculate:#{refId}", => @calculate(refId))
    @

  calculate: (refId) ->
    definition = @_refs[refId]
    unless definition
      @_logger.error "cannot calculate value, missing reference to #{refId}"
      @trigger("calculated:#{refId}", null)
      return @

    # shortcut for memoized values (already computed)
    value = @_memoized[refId]
    unless _.isUndefined(value)
      @trigger("calculated:#{refId}", value)
      return @

    method = @methods[definition.method]
    unless method
      @_logger.error "undefined calc method for #{refId}"
      @trigger("calculated:#{refId}", null)
      return @

    triggers = {}
    triggerCount = 0
    values = _.clone(definition.values || definition.value)
    values = [values] unless _.isArray(values)
    for value, idx in values
      # lookup references to other definitions
      if _.isObject(value) && value.ref
        value = @dereference(value)
        values[idx] = value

      # if named definition then fetch asynchronously
      if _.isObject(value) && value.name
        valName = value.name
        triggers[valName] = (value) =>
          @off("calculated:#{valName}", triggers[valName])
          delete triggers[valName]
          values[idx] = value

          # if triggers list empty then everything evaluated, run callback
          if (triggerCount -= 1) == 0
            method values, definition, (result) =>
              if @afterCalculate then result = @afterCalculate(result)
              unless definition.memoize is false then @_memoized[refId] = result
              @trigger("calculated:#{refId}", result)

        triggerCount += 1
        @on("calculated:#{valName}", triggers[valName])

    if _.isEmpty(triggers)
      # all values are currently known, no need trigger value calculations
      method values, definition, (result) =>
        if @afterCalculate then result = @afterCalculate(result)
        unless definition.memoize is false then @_memoized[refId] = result
        @trigger("calculated:#{refId}", result)
    else
      # one or more value triggers prepared, trigger calculations
      @trigger("calculate:#{key}") for key, val of triggers
    @

  genRefId: ->
    # possibility of collisions but unlikely given expected num of definitions
    'def#' + Math.floor(Math.random() * 999999 + 1)

  dereference: (value) ->
    return null unless _.isObject(value) && value.ref

    newVal = @_refs[value.ref]
    if _.isUndefined(newVal)
      @_logger.error "dereferencing to unknown definition #{value.ref}"
      return null
    newVal

  defaultMethods:
    value: (values, options, callback) ->
      callback(values)

    sum: (values, options, callback) ->
      callback(_.reduce(_.flatten(values), ((a,v) => a + v), 0))

    count: (values, options, callback) ->
      flatValues = _.flatten(values)
      filteredResults = _.filter flatValues, (value) =>
        if options.count_if_equal_to != undefined
          value == options.count_if_equal_to
        else if options.count_if_not_equal_to != undefined
          value == options.count_if_not_equal_to
        else
          true
      callback(_.size(filteredResults))

    pluck: (values, options, callback) ->
      keyChain = _.compact((options.keypath||"").split(/[.\[\]]/))
      result = _.map _.flatten(values), (value) =>
        _.reduce keyChain, (val,key) =>
            val ?= {}
            if val.get then val.get(key) else val[key]
          , value
      callback(result)
