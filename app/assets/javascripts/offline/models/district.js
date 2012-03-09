Models.District = Backbone.RelationalModel.extend({
  database: provinceDb,
  storeName: "districts",
  idAttribute: 'code',

  relations: [{
    type: Backbone.HasMany,
    key: 'healthCenters',
    relatedModel: 'Models.HealthCenter',
    collectionType: 'Collections.HealthCenters',
  }],

});
