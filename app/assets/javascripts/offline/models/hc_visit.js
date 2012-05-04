Models.HcVisit = Backbone.NestedModel.extend({
  database: provinceDb,
  storeName: "hc_visits",
  idAttribute: 'code',

  defaults: {
    visited: null,
    visited_at: null,
    vehicle_id: null,
    non_visit_reason: null,
    other_non_visit_reason: null,
    refrigerators: null,
  },

  initialize: function() {
    var result;
    if (result = this.get('code').match(/^(.+?)-(\d{4}-\d{2})$/)) {
      this.set({ health_center_code: result[1], month: result[2] });
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

Models.DirtyHcVisit = Models.HcVisit.extend({
  database: provinceDb,
  storeName: "dirty_hc_visits",
  idAttribute: 'code',

  isEditable: function() {
    return true;
  },

});
