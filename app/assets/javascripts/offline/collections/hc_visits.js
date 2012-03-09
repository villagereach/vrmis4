Collections.HcVisits = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "hc_visits",
  model: Models.HcVisit,

});
