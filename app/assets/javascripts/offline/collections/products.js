Collections.Products = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "products",
  model: Models.Product,

  comparator: function(package) {
    return package.get('code');
  },

});
