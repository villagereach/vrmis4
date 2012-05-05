class Views.HcVisits.EditRdtInventory extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_rdt_inventory']

  className: 'edit-rdt-inventory-screen'
  tabName: 'rdt-inventory'

  initialize: (options) ->
    super(options)

    testPkgs = options.packages.filter (p) => p.get('product_type') is 'test'
    @packages = new Collections.Packages(testPkgs)

  refreshState: (newState) ->
    super(if @hcVisit.get('visited') is false then 'disabled' else newState)
