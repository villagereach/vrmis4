Models.Product = Backbone.RelationalModel.extend({
  database: provinceDb,
  storeName: "products",
  idAttribute: 'code',

  relations: [{
    type: Backbone.HasMany,
    key: 'packages',
    relatedModel: 'Models.Package',
    collectionType: 'Collections.Packages',
    reverseRelation: { key: 'product' },
  }],

});
