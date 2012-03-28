Models.Product = Backbone.Model.extend({
  database: provinceDb,
  storeName: "products",
  idAttribute: 'code',

  get: function (attr) {
    if (typeof this[attr] == 'function') { return this[attr]() };
    return Backbone.Model.prototype.get.call(this, attr);
  },

  packages: function() {
    var code = this.get('code');
    var packages = App.packages.filter(function(pkg) {
      return pkg.get('product_code') == code;
    });

    return new Collections.Packages(packages);
  },

});
