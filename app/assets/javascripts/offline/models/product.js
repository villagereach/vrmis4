Models.Product = Backbone.RelationalModel.extend({
  idAttribute: 'code',

  relations: [{
    type: Backbone.HasMany,
    key: 'packages',
    relatedModel: 'Models.Package',
    collectionType: 'Collections.Packages',
    reverseRelation: { key: 'product' },
  }],

});
