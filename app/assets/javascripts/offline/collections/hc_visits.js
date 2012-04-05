Collections.HcVisits = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "hc_visits",
  model: Models.HcVisit,

});

Collections.DirtyHcVisits = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "dirty_hc_visits",
  model: Models.DirtyHcVisit,

});
