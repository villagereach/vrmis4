Collections.DeliveryZones = Backbone.Collection.extend({
  localStorage: new Store('DeliveryZones'),
  model: Models.DeliveryZone,

});
