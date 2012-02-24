Models.District = Backbone.RelationalModel.extend({
  idAttribute: 'code',

  relations: [{
    type: Backbone.HasMany,
    key: 'healthCenters',
    relatedModel: 'Models.HealthCenter',
    collectionType: 'Collections.HealthCenters',
  }],

});
