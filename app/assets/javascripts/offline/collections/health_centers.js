Collections.HealthCenters = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "health_centers",
  model: Models.HealthCenter,

  comparator: function(hc) {
    return hc.get('code');
  },

  get: function (attr) {
    if (typeof this[attr] == 'function') { return this[attr]() };
    return Backbone.Model.prototype.get.call(this, attr);
  },

  sum: function(attr) {
    return this.reduce(function(acc,hc) {
      var val = hc.get(attr);
      return _.isNumber(val) ? acc + val : acc;
    }, 0);
  }

});
