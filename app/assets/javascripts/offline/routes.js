var OfflineRouter = Backbone.Router.extend({
  routes: {
    "hc_visits/:code":               "hc_visits_edit",
    "hc_visits/:code/visit":         "hc_visits_edit_visit_info",
    "hc_visits/:code/refrigerators": "hc_visits_edit_refrigerators",
    "hc_visits/:code/epi_inventory": "hc_visits_edit_epi_inventory",
  },

  hc_visits_edit: function() {
    App.render();
  },

  hc_visits_edit_visit_info: function() {
    App.selectTab("tab-visit-info");
  },

  hc_visits_edit_refrigerators: function() {
    App.selectTab("tab-refrigerators");
  },

  hc_visits_edit_epi_inventory: function() {
    App.selectTab("tab-epi-inventory");
  },

});
