Collections.Packages = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "packages",
  model: Models.Package,

  comparator: function(package) {
    return package.get('code');
  },

});
