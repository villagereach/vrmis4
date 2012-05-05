class Views.Reports.Adhoc extends Backbone.View
  template: JST['offline/templates/reports/adhoc']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click  .definition-name a':           'calcDefinition'
    'click  #reports-adhoc-calculate':     'calculate'
    'change #reports-adhoc-month':         'selectMonth'
    'change #reports-adhoc-delivery_zone': 'selectDeliveryZone'
    'change #reports-adhoc-district':      'selectDistrict'
    'change #reports-adhoc-definitions':   'changeDefinitions'

  defaultDefinitions: [
    # see rebuildCalcGraph method for dynamic definitions (hcVisits, etc)
    {
      name: 'products'
      method: 'collection'
      collection: 'Products'
    }
    {
      name: 'packages'
      method: 'collection'
      collection: 'Packages'
    }
    {
      name: 'stockCards'
      method: 'collection'
      collection: 'StockCards'
    },
    {
      name: 'equipmentTypes'
      method: 'collection'
      collection: 'EquipmentTypes'
    }
  ]

  initialize: (options) ->
    @months = options.months
    @deliveryZones = App.deliveryZones
    @districts = App.districts
    @definitions = []
    @customDefinitions = []
    @month = @months[0]

    @rebuildCalcGraph()

  render: ->
    @delegateEvents()
    @$el.html @template(@)
    @$('#reports-adhoc-definitions').focus()
    @

  close: ->
    @undelegateEvents()
    @unbind()

  rebuildCalcGraph: ->
    conditions = {}
    if @districtCode then conditions.district_code = @districtCode
    if @dzCode then conditions.delivery_zone_code = @dzCode

    hcvConditions = _.clone(conditions)
    hcvConditions.month = @month
    hcvVisitedConditions = _.clone(hcvConditions)
    hcvVisitedConditions.visited = true

    builtinDefinitions = [
      {
        name:       'hcVisits'
        method:     'collection'
        collection: 'HcVisits'
        index:      'month'
        conditions: hcvConditions
      }
      {
        name:    'hcVisitsCount'
        method:  'count'
        values:  {'ref': 'hcVisits'}
      }
      {
        name:   'hcVisitsVisited'
        method:  'collection'
        collection: 'HcVisits'
        index: 'month'
        conditions:  hcvVisitedConditions
      }
      {
        name:  'hcVisitsVisitedCount'
        method: 'count'
        values:  {'ref': 'hcVisitsVisited'}
      }
      {
        name: 'VisitedValues'
        method: 'pluck'
        keypath: 'visited'
        values: {'ref': 'hcVisits'}
      }
      {
        name: 'hcVisitsVisitedCount2'
        method: 'count'
        count_if_equal_to: true,
        values:  {'ref':  'VisitedValues'}
      }
      {
        name: 'hcVisitsVisitedCount3'
        method: 'count'
        count_if_not_equal_to: false
        values:  {'ref':  'VisitedValues'}
      }
      {
        name: 'hcVisitsNOTVisitedCount'
        method: 'count'
        count_if_equal_to: false
        values:  {'ref':  'VisitedValues'}
      }
      {
        name:       'healthCenters'
        method:     'collection'
        collection: 'HealthCenters'
        conditions: conditions
      }
      {
        name:  'healthCentersCount'
        method: 'count'
        values: {'ref': 'healthCenters'}
      }
    ]
    @definitions = _.union @defaultDefinitions, builtinDefinitions, @customDefinitions

    @calcGraph = new Models.CalcGraph
      methods: @calcMethods
      definitions: @definitions
      afterCalculate: (values) =>
        if _.isArray(values)
          values.map (value) => if value is 'NR' then null else value
        else
          if values is 'NR' then null else values

  selectMonth: ->
    @month = @$('#reports-adhoc-month').val() || null
    @rebuildCalcGraph()

  selectDeliveryZone: ->
    @dzCode = @$('#reports-adhoc-delivery_zone').val() || null
    @districts = if @dzCode then @deliveryZones.get(@dzCode).get('districts') else App.districts
    @districtCode = null
    @rebuildCalcGraph()
    @

  selectDistrict: ->
    @districtCode = @$('#reports-adhoc-district').val() || null
    @rebuildCalcGraph()

  changeDefinitions: ->
    @definitionsJSON = @$('#reports-adhoc-definitions-json').val()

    try
      @customDefinitions = JSON.parse('[' + @definitionsJSON + ']')
      @definitionErrors = null
      @rebuildCalcGraph()
    catch err
      @definitionErrors = err

    @render()

  calculate: ->
    # don't really want to do anything, just let ui refresh definitions

  calcDefinition: (e, definition) ->
    definitionName = definition?.name || e.target.text

    valueElem = @$('#reports-adhoc-value')
    valueElem.val('calculating...')

    callback = (result) =>
      valueElem.val(result)
      @calcGraph.off("calculated:#{definitionName}", callback)
      @$("#reports-adhoc-value").val(result)
      @$("#reports-adhoc-value-json").html(JSON.stringify(result, undefined, 2))
    @calcGraph.on("calculated:#{definitionName}", callback)
    @calcGraph.trigger("calculate:#{definitionName}")

  calcMethods:
    collection: (values, options, callback) ->
      colCons = Collections[options.collection]
      if !colCons then throw "collection not found for #{options.collection}"
      collection = new colCons

      indexedConds = null
      if options.conditions && options.conditions[options.index]
        indexedConds = {}
        indexedConds[options.index] = options.conditions[options.index]

      otherConds = _.clone(options.conditions||{})
      if options.index then delete otherConds[options.index]

      collection.fetch
        conditions: indexedConds
        success: =>
          objs = collection.toArray()
          for k,v of otherConds
            objs = objs.filter (obj) => obj.get(k) == val
          callback(objs)
