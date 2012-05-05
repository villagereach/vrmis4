class Views.HcVisits.EditEpiInventory extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_epi_inventory']

  className: 'edit-epi-inventory-screen'
  tabName: 'epi-inventory'

  initialize: (options) ->
    super(options)

    nonTestPkgs = options.packages.filter (p) => p.get('product_type') isnt 'test'
    @packages = new Collections.Packages(nonTestPkgs)

  refreshState: (newState) ->
    super(if @hcVisit.get('visited') is false then 'disabled' else newState)
