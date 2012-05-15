class Views.HcVisits.EditScreen extends Backbone.View
  tableField: JST['offline/templates/hc_visits/table_field']

  tagName: 'div'
  state: null, # starting state is unknown

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'change input, textarea': 'change'

  vh: Helpers.View
  dh: Helpers.Date
  t: Helpers.View.t
  target_pcts: Helpers.Targets.target_pcts

    
  initialize: (options) ->
    @[k] = v for k,v of options

  render: ->
    @delegateEvents()
    @$el.html @template(@)
    @

  close: ->
    @undelegateEvents()
    @remove()
    @unbind()
    @

  change: (e) ->
    elem = e.target
    $elem = @$(elem)

    obj = @hcVisit
    type = elem.type
    name = elem.name
    value = null

    if type is 'number'
      value = if Number(elem.value).toString() is elem.value then Number(elem.value) else null
      obj.set(name, value)

    else if type is 'radio'
      value = elem.value

      # convert booleans from string to Boolean
      if value.match /^(?:true|false)$/
        value = (value is 'true')

      obj.set(name, value)

    else if type is 'checkbox'
      parts = name.match /^(.+)\[\]$/
      if parts # parts[0] is name w/o '[]', parts[1] is name w/ '[]'
        # multiple checkboxes, actual name is w/o trailing '[]'
        name = parts[1]

        # initialize w/ empty array if undefined
        unless origVal = obj.get(name, {silent: true})
          obj.set(name, origVal = [])

        if elem.checked
          obj.add(name, elem.value)
        else
          if (idx = origVal.indexOf(elem.value)) >= 0
            obj.remove("#{name}[#{idx}]")

        # returned value should be a complete list of checked values
        # note: checkboxes could be a subset of model values, return actual
        $valueElems = @$("input[name=\"#{parts[0]}\"]:checked")
        value = $valueElems.map(-> @value).toArray()

      else
        # single checkbox
        value = if elem.checked then elem.value else null
        obj.set(name, value)

    else
      value = @cleanupValue(name, elem.value)
      value = null if value is ''
      obj.set(name, value)

    @validateElement(elem, value)

    if $elem.hasClass('render')
      # changes to this element require a complete screen re-render
      @render()
    else
      # at a minimum, we need to clean up any NR-related fields
      @handleNR(e)

    @refreshState()
    [name, value]

  cleanupValue: (name, value) ->
    value?.trim()

  validateElement: (elem, value, isValid = null) ->
    $xElem = @$("[id=\"#{elem.name}-x\"]")

    isValid ?= false if !value? || value is '' # null or empty string
    isValid ?= false if _.isArray(value) && _.isEmpty(value) # empty array
    isValid ?= true

    if isValid
      $xElem.removeClass('x-invalid').addClass('x-valid')
    else
      $xElem.removeClass('x-valid').addClass('x-invalid')

  handleNR: (e) ->
    elem = e.target
    $elem = @$(elem)

    if $elem.hasClass('nr')
      valId = elem.id.replace /-nr$/, ''
      $valElem = @$("##{valId}")
      $valElem.val('')
    else
      nrId = "#{elem.id}-nr"
      $nrElem = @$("##{nrId}")
      $nrElem.attr('checked', false)

  refreshState: (newState) ->
    newState ?= 'complete' if @$(".x-invalid").length == 0
    newState ?= 'todo' if @$(".x-valid").length == 0
    newState ?= 'incomplete'

    if newState != @state
      @state = newState
      @trigger('change:state', newState)
