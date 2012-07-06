class Views.WarehouseVisits.Ideal extends Backbone.View
  template: JST['offline/templates/warehouse_visits/ideal']

  el: '#offline-container'

  vh: Helpers.View
  t: Helpers.View.t

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow

  initialize: (options) ->
    @month = options.month
    @deliveryZone = options.deliveryZone
    @districts = @deliveryZone.get('districts')
    @productTypes = ['vaccine','syringe','safety']

    @pkgsByType = {}
    for type in @productTypes
      pkgs = options.packages.filter (p) => p.get('product_type') is type
      @pkgsByType[type] = new Collections.Packages(pkgs)

    @pkgsOrdered = _.chain(@productTypes)
      .map((type) => @pkgsByType[type].toArray())
      .flatten()
      .value()

    @districtTotals = {}
    @districts.each (district) =>
      districtCode = district.get('code')
      healthCenters = district.get('healthCenters')

      @districtTotals[districtCode] =
        population: healthCenters.sum('population')

      options.packages.each (pkg) =>
        pkgCode = pkg.get('code')
        @districtTotals[districtCode][pkgCode] =
          healthCenters.sum("ideal_stock_by_pkg.#{pkgCode}")

    @deliveryZoneTotal =
      population: _(@districtTotals).pluck('population').reduce(((acc,v) => acc + v), 0)

    for pkgCode in options.packages.pluck('code')
      @deliveryZoneTotal[pkgCode] = _(@districtTotals).pluck(pkgCode)
        .reduce(((acc,v) => acc + v), 0)

  render: ->
    @delegateEvents()
    @$el.html @template(@)
    @

  close: ->
    @undelegateEvents()
    @unbind()
    @
