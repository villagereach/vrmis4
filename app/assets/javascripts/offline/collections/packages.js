Collections.Packages = Backbone.Collection.extend({
  model: Models.Package,

  comparator: function(package) {
    return package.get('code');
  },

});
