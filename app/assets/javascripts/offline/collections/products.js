Collections.Products = Backbone.Collection.extend({
  localStorage: new Store('Products'),
  model: Models.Product,

});
