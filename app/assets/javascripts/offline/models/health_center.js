Models.HealthCenter = Backbone.RelationalModel.extend({
  database: provinceDb,
  storeName: "health_centers",
  idAttribute: 'code',

});
