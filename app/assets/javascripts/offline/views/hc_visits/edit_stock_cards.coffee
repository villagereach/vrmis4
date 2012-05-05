class Views.HcVisits.EditStockCards extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_stock_cards']

  className: 'edit-stock-cards-screen'
  tabName: 'stock-cards'

  refreshState: (newState) ->
    super(if @hcVisit.get('visited') is false then 'disabled' else newState)
