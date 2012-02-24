Collections.Products = Backbone.Collection.extend({
  localStorage: new Store('Products'),
  model: Models.Product,

  comparator: function(package) {
    return package.get('code');
  },

});
