Models.HcVisit = Backbone.Model.extend({
  defaults: {
    visited: true,
    visited_at: null,
    vehicle_id: null,
    non_visit_reason: null,
    other_non_visit_reason: null,
    refrigerators: [],
  },

  initialize: function() {
  },

});


//class OfflineApp.Models.HcVisit extends Backbone.Model

//class Vrmis.Models.HcVisit extends Backbone.Model
//  paramRoot: 'hc_visit'

//  defaults:
//    visited: null
//    visited_at: null
//    vehicle_id: null
//    non_visit_reason: null

//class Vrmis.Collections.HcVisitsCollection extends Backbone.Collection
//  model: Vrmis.Models.HcVisit
//  url: '/hc_visits'
