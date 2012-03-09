Collections.HealthCenters = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "health_centers",
  model: Models.HealthCenter,

});
