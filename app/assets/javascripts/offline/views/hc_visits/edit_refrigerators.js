Views.HcVisits.EditRefrigerators = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_refrigerators'],

  className: 'edit-refrigerators-screen',
  tabName: 'refrigerators',

  events: _.extend(_.clone(Views.HcVisits.EditScreen.prototype.events), {
    'click .add-fridge': 'addFridge',
    'click .del-fridge': 'delFridge',
  }),

  EMPTY_FRIDGE: { running_problems: [] },

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);

    if (!this.hcVisit.get('refrigerators', { silent: true })) {
      this.hcVisit.set('refrigerators', [_.clone(this.EMPTY_FRIDGE)], { silent: true });
    }
  },

  addFridge: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.hcVisit.add('refrigerators', _.clone(this.EMPTY_FRIDGE));

    this.render();
    this.refreshState();
  },

  delFridge: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var elem = e.target
    var idx = elem.dataset.refrigeratorIdx;
    this.hcVisit.remove('refrigerators['+idx+']');

    this.render();
    this.refreshState();
  },

});
