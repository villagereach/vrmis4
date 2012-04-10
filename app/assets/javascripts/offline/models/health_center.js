Models.HealthCenter = Backbone.NestedModel.extend({
  database: provinceDb,
  storeName: "health_centers",
  idAttribute: 'code',

});
