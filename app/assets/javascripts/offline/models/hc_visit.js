Models.HcVisit = Backbone.Model.extend({
  database: provinceDb,
  storeName: "hc_visits",
  idAttribute: 'code',

  defaults: {
    visited: true,
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

  deepGet: function(key) { // "foo.bar.baz" format
    return _.foldl(_.compact(key.split(/[.\[\]]/)), function(val,key) {
      val = val || {};
      return val.get ? val.get(key) : val[key]
    }, this);
  },

  toJSON: function() {
    // include the object's id, needed for backbone-indexeddb
    return _.clone(_.extend(this.attributes, {id: this.id}));
  },

});
