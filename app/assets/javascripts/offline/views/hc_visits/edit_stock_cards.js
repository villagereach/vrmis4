Views.HcVisits.EditStockCards = Views.HcVisits.EditScreen.extend({
  template: JST["offline/templates/hc_visits/edit_stock_cards"],

  className: "edit-stock-cards-screen",
  tabName: "stock-cards",

  refreshState: function(newState) {
    newState = this.hcVisit.get('visited') === false ? 'disabled' : newState;
    return this.super.refreshState.apply(this, [newState]);
  },

});
