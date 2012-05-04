Models.HealthCenter = Backbone.NestedModel.extend({
  database: provinceDb,
  storeName: "health_centers",
  idAttribute: 'code',

  get: function(attr, opts) {
    var keys = Backbone.NestedModel.attrPath(attr);
    if (_.isFunction(this[keys[0]])) {
      // first part of keypath is a method local to object, apply method first
      var val = this[keys.shift()]();

      if (!keys.length) {
        // no part of keypath remains, this is our value
        return val;
      } else if (_.isFunction(val.get)) {
        // local method returned an object w/ a get() method, use it
        return val.get(keys.join('.'), opts);
      } else {
        // assume plain objects for the rest of the keypath
        return keys.reduce(function(v,k) { return (v||{})[k] }, val);
      }

    } else {
      // no local function matching key, call prototype/super method
      return Backbone.NestedModel.prototype.get.call(this, attr, opts);
    }
  },

  ideal_stock_by_pkg: _.memoize(function() {
    var isas = this.get('ideal_stock_amounts', { silent: true });
    return App.packages.reduce(function(h, pkg) {
      h[pkg.get('code')] = Math.round((isas[pkg.get('product_code')] || 0) / pkg.get('quantity'));
      return h;
    }, {});
  }, function() { return this.get('id') }), // memoize by health center id

});
