Models.Package = Backbone.RelationalModel.extend({
  database: provinceDb,
  storeName: "packages",
  idAttribute: 'code',

});
