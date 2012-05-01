Collections.WarehouseVisits = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "warehouse_visits",
  model: Models.WarehouseVisit,

});

Collections.DirtyWarehouseVisits = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "dirty_warehouse_visits",
  model: Models.DirtyWarehouseVisit,

});
