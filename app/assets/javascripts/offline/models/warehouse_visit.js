Models.WarehouseVisit = Backbone.NestedModel.extend({
  database: provinceDb,
  storeName: 'warehouse_visits',
  idAttribute: 'code',

  initialize: function() {
    var result;
    if (result = this.get('code').match(/^(.+?)-(\d{4}-\d{2})$/)) {
      this.set({ delivery_zone_code: result[1], month: result[2] });
    }
  },

  isEditable: function() {
    return false;
  },

  toJSON: function() {
    // include the object's id, needed for backbone-indexeddb
    return _.clone(_.extend(this.attributes, {id: this.id}));
  },

});

Models.DirtyWarehouseVisit = Models.WarehouseVisit.extend({
  database: provinceDb,
  storeName: 'dirty_warehouse_visits',
  idAttribute: 'code',

  isEditable: function() {
    return true;
  },

});
