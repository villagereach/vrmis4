Models.DeliveryZone = Backbone.RelationalModel.extend({
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
