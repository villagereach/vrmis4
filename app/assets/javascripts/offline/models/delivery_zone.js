Models.DeliveryZone = Backbone.RelationalModel.extend({
  database: provinceDb,
  storeName: "delivery_zones",

  idAttribute: 'code',

  relations: [{
    type: Backbone.HasMany,
    key: 'districts',
    relatedModel: 'Models.District',
    collectionType: 'Collections.Districts',
    reverseRelation: {
      key: 'deliveryZone',
    },
  }],

});
