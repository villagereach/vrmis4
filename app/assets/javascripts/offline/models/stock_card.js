Models.StockCard = Backbone.Model.extend({
  database: provinceDb,
  storeName: "stock_cards",
  idAttribute: 'code',

});
