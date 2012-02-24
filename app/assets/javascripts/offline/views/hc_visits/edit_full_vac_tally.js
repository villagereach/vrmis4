Views.HcVisits.EditFullVacTally = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_full_vac_tally"],

  tagName: "div",
  className: "edit-full-vac-tally-screen",
  tabName: "tab-full-vac-tally",
  state: "todo",

  events: {
    "change .input":  "inputChange",
    "click .nr":      "nrChange",
  },

  initialize: function(options) {
    var that = this;
    this.model.on('change:visited', function() {
      that.refreshState();
      that.trigger('refresh:tabs');
    });

    if (this.model.get('visited') === false) { this.state = 'disabled' }
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template({
      fullVacTally: (this.model.get('full_vac_tally') || {}),
    }));

    this.validate();
    this.refreshState();

    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.remove();
    this.unbind();
  },

  nrChange: function(e) {
    var elem = e.srcElement;

    var $inputField = this.$('#' + elem.id.slice(0, -3)); // removes trailing "-nr"
    if (elem.checked) { $inputField.val(null); }

    this.change(e, $inputField[0]);
  },

  inputChange: function(e) {
    var elem = e.srcElement;

    var $nrCheckbox = this.$('#' + elem.id + '-nr');
    if ($nrCheckbox.attr('checked')) { $nrCheckbox.attr('checked', false); }

    this.change(e, elem);
  },

  change: function(e, elem) { // where elem is the real element, not NR boxes
    elem = elem || e.srcElement;

    var attrs = this.serialize();
    this.model.set('full_vac_tally', attrs.full_vac_tally);

    this.validateElement(e, elem);
    this.refreshState();
  },

  serialize: function() {
    var attrs = this.$("form").toObject({ skipEmpty: false, emptyToNull: true });

    // poplulate full_vac_tally values w/ NR for all checked NR boxes
    var fullVacTally = attrs.full_vac_tally;
    var nrVals = attrs.nr.full_vac_tally;
    _.each(fullVacTally, function(categories,code) {
      _.each(categories, function(qty, category) {
        if (nrVals[code][category]) { fullVacTally[code][category] = 'NR'; }
      });
    });

    return { full_vac_tally: fullVacTally };
  },

  validate: function() {
    var that = this;
    this.$(".validate").each(function(idx,elem) { that.validateElement(null, elem); });
  },

  validateElement: function(e, elem) {
    elem = elem || e.srcElement;
    if (!this.$(elem).hasClass("validate")) { return; }

    // add additional statements for special cases here

    // NOTE: currently going off model, which requires updating model first
    // as it was going to require dealing with radio/checkboxes/etc otherwise

    var value = this.model.deepGet(elem.name);
    if (value != null) {
      this.$('#'+elem.id+'-x').removeClass('x-invalid').addClass('x-valid');
      return;
    } else {
      this.$('#'+elem.id+'-x').removeClass('x-valid').addClass('x-invalid');
      return "is invalid";
    }
  },

  refreshState: function(e) {
    this.state = this.checkState();
    return this;
  },

  checkState: function(e) {
    if (this.$(".x-invalid").length == 0) return "complete";
    if (this.$(".x-valid").length == 0) return "todo";
    return "incomplete";
  },

});
