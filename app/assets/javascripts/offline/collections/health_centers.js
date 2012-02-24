Collections.HealthCenters = Backbone.Collection.extend({
  localStorage: new Store('HealthCenters'),
  model: Models.HealthCenter,

});
