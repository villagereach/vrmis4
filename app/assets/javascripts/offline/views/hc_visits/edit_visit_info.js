Views.HcVisits.EditVisitInfo = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_visit_info'],

  className: 'edit-visit-info-screen',
  tabName: 'visit-info',

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);
    this.screenPos = 1;
  },

});
