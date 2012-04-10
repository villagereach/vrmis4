Views.HcVisits.EditFullVacTally = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_full_vac_tally'],

  className: 'edit-full-vac-tally-screen',
  tabName: 'full-vac-tally',

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);
    this.screenPos = 9;
  },

});
