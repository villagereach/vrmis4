Views.HcVisits.EditStockCards = Views.HcVisits.EditScreen.extend({
  template: JST["offline/templates/hc_visits/edit_stock_cards"],

  className: "edit-stock-cards-screen",
  tabName: "stock-cards",

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);
    this.screenPos = 6;
  },

});
