class Views.WarehouseVisits.Edit extends Backbone.View
  template: JST['offline/templates/warehouse_visits/form']
  tableField: JST['offline/templates/warehouse_visits/table_field']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'change input, textarea': 'change'

  vh: Helpers.View
  t: Helpers.View.t

  initialize: (options) ->
    @[k] = v for k,v of options
    @districts = @deliveryZone.get('districts')
    @healthCenters = @deliveryZone.get('healthCenters')
    @productTypes = ['vaccine', 'syringe', 'test', 'safety', 'fuel']

    @pkgsByType = {}
    for type in @productTypes
      pkgs = options.packages.filter (p) => p.get('product_type') is type
      @pkgsByType[type] = new Collections.Packages(pkgs)

    @idealStock = {}
    options.packages.each (pkg) =>
      pkgCode = pkg.get('code')
      @idealStock[pkgCode] = @healthCenters.sum("ideal_stock_by_pkg.#{pkgCode}")

  render: ->
    @delegateEvents()
    @$el.html @template(@)
    @

  close: ->
    @undelegateEvents()
    @unbind()
    @

  change: (e) ->
    elem = e.target
    $elem = @$(elem)

    obj = @warehouseVisit
    type = elem.type
    name = elem.name
    value = null

    if type is 'number'
      value = if Number(elem.value).toString() is elem.value then Number(elem.value) else null
      obj.set(name, value)
    else
      value = elem.value
      value = null if value is ''
      obj.set(name, value)

    @validateElement(elem, value)

    @refreshState()
    [name, value]

  validateElement: (elem, value) ->
    $xElem = @$("[id=\"#{elem.name}-x\"]")
    if value? && value isnt '' && !(_.isArray(value) && _.isEmpty(value))
      $xElem.removeClass('x-invalid').addClass('x-valid')
    else
      $xElem.removeClass('x-valid').addClass('x-invalid')

  refreshState: (newState) ->
    newState ?= 'complete' if @$(".x-invalid").length == 0
    newState ?= 'todo' if @$(".x-valid").length == 0
    newState ?= 'incomplete'

    if newState != @state
      @state = newState
      @trigger('change:state', newState)
