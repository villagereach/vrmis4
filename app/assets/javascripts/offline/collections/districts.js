Collections.Districts = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "districts",
  model: Models.District,

  comparator: function(district) {
    return district.get('code');
  },

});
