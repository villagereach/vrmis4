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
    this.screenPos = 2;

    if (!this.hcVisit.get('refrigerators', { silent: true })) {
      this.hcVisit.set('refrigerators', [_.clone(this.EMPTY_FRIDGE)], { silent: true });
    }
  },

  addFridge: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.hcVisit.add('refrigerators', _.clone(this.EMPTY_FRIDGE));

    this.render();
  },

  delFridge: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var elem = e.srcElement
    var idx = elem.dataset.refrigeratorIdx;
    this.hcVisit.remove('refrigerators['+idx+']');

    this.render();
  },

//initialize: function() {
//  // if never been a refrigerator then let's start with a blank one
//  if (!this.model.get('refrigerators')) { this.model.set('refrigerators', [{}]); }

//  var that = this;
//  this.model.on('change:visited', function() {
//    that.refreshState();
//    that.trigger('refresh:tabs');
//  });

//  if (this.model.get('visited') === false) { this.state = 'disabled' }
//},

//serialize: function() {
//  var attrs = this.$("form").toObject({ skipEmpty: false, emptyToNull: true });

//  // remove nulls from refrigerators[*].running_problems[]
//  _.each(attrs.refrigerators, function(r) {
//    r.running_problems = _.without(r.running_problems, null);
//  });

//  return attrs;
//},

//validate: function() {
//  var that = this;
//  this.$(".validate").each(function(idx,elem) { that.validateElement(null, elem); });
//},

//validateElement: function(e, elem) {
//  elem = elem || e.srcElement;
//  if (!this.$(elem).hasClass("validate")) { return; }

//  // add additional statements for special cases here

//  // NOTE: currently going off model, which requires updating model first
//  // as it was going to require dealing with radio/checkboxes/etc otherwise

//  var elemId = '#hc_visit-' + elem.name.replace(/[.\[\]]+/g, '-').replace(/-$/, '') + '-x'

//  var value = this.model.deepGet(elem.name);
//  if (value instanceof Array ? value.length > 0 : value) {
//    this.$(elemId).removeClass('x-invalid').addClass('x-valid');
//    return;
//  } else {
//    this.$(elemId).removeClass('x-valid').addClass('x-invalid');
//    return "is invalid";
//  }
//},

//refreshState: function(e) {
//  this.state = this.checkState();
//  return this;
//},

//checkState: function(e) {
//  if (!this.model.get("visited")) { return "disabled"; }
//  if (this.$(".x-invalid").length == 0) return "complete";
//  if (this.$(".x-valid").length == 0) return "todo";
//  return "incomplete";
//},

});
