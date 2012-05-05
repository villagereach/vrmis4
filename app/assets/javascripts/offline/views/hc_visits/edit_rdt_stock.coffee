class Views.HcVisits.EditRdtStock extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_rdt_stock']

  className: 'edit-rdt-stock-screen'
  tabName: 'rdt-stock'

  initialize: (options) ->
    super(options)

    testPkgs = options.packages.filter (p) => p.get('product_type') is 'test'
    @packages = new Collections.Packages(testPkgs)
