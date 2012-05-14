class Views.WarehouseVisits.Show extends Backbone.View
  template: JST['offline/templates/warehouse_visits/form']
  tableField: JST['offline/templates/warehouse_visits/table_field']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #edit-visit': -> @trigger 'navigate', "#warehouse_visits/#{@warehouseVisit.get('code')}/edit", true
    'focus input, textarea': (e) -> e.target.blur()

  vh: Helpers.View
  dh: Helpers.Date
  t: Helpers.View.t

  initialize: (options) ->
    @[k] = v for k,v of options
    @districts = @deliveryZone.get('districts')
    @healthCenters = @deliveryZone.get('healthCenters')
    @productTypes = ['vaccine', 'syringe', 'test', 'safety', 'fuel']
    @readonly = true

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
    @checkEditability()
    @

  close: ->
    @undelegateEvents()
    @unbind()
    @

  checkEditability: ->
    $elem = @$('#edit-visit')
    $elem.hide()

    $.getJSON "#{App.baseUrl}/users/current", (user) =>
      $elem.show() if user?.role == 'admin'
