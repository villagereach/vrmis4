Collections.HealthCenters = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "health_centers",
  model: Models.HealthCenter,

  comparator: function(hc) {
    return hc.get('code');
  },

  sum: function(attr) {
    return this.reduce(function(acc,hc) {
      var val = hc.get(attr);
      return _.isNumber(val) ? acc + val : acc;
    }, 0);
  }

});
