Models.HcVisit = Backbone.Model.extend({
  idAttribute: 'code',

  defaults: {
    visited: true,
    visited_at: null,
    vehicle_id: null,
    non_visit_reason: null,
    other_non_visit_reason: null,
    refrigerators: [],
  },

  initialize: function() {
    var result;
    if (result = this.get('code').match(/^(.+?)-(\d{4}-\d{2})$/)) {
      this.set({ health_center_code: result[1], month: result[2] });
    }
  },

  deepGet: function(key) { // "foo.bar.baz" format
    return _.foldl(key.split('.'), function(val,key) {
      val = val || {};
      return val.get ? val.get(key) : val[key]
    }, this);
  }

});
