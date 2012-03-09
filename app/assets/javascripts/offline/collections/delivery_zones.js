Collections.DeliveryZones = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "delivery_zones",
  model: Models.DeliveryZone,

});
