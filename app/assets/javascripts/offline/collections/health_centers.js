Collections.HealthCenters = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "health_centers",
  model: Models.HealthCenter,

  comparator: function(hc) {
    return hc.get('code');
  },

});
