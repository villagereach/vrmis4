Models.Package = Backbone.Model.extend({
  database: provinceDb,
  storeName: "packages",
  idAttribute: 'code',

  get: function (attr) {
    if (typeof this[attr] == 'function') { return this[attr]() };
    return Backbone.Model.prototype.get.call(this, attr);
  },

  product: function() {
    return App.products.get(this.get('product_code'));
  },

  product_type: function() {
    return this.get('product').get('product_type');
  },

});
