Collections.StockCards = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "stock_cards",
  model: Models.StockCard,

  comparator: function(sc) {
    return sc.get('code');
  },

});
