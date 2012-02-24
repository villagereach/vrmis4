Views.HcVisits.EditEquipmentStatus = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_equipment_status"],

  tagName: "div",
  className: "edit-equipment-status",
  tabName: "tab-equipment-status",
  state: "todo",

  events: {
    "change":    "change",
    "click .nr": "nrChange",
  },

  initialize: function(options) {
    if (!this.model.get('equipment_status')) {
      this.model.set('equipment_status', {});
    }

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
      equipmentStatus: this.model.get('equipment_status'),
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

  numberChange: function(e) {
    var elem = e.srcElement;

    var $nrCheckbox = this.$('#' + elem.id + '-nr');
    if ($nrCheckbox.attr('checked')) { $nrCheckbox.attr('checked', false); }

    this.change(e, elem);
  },

  change: function(e, elem) { // where elem is the real element, not NR boxes
    elem = elem || e.srcElement;

    var attrs = this.serialize();
    this.model.set('equipment_status', attrs.equipment_status);

    this.validateElement(e, elem);
    this.refreshState();
  },

  serialize: function() {
    return this.$("form").toObject({ skipEmpty: false, emptyToNull: true });
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

    var elemId = '#hc_visit-' + elem.name.replace(/[.\[\]]+/g, '-').replace(/-$/, '') + '-x'

    if (this.model.deepGet(elem.name)) {
      this.$(elemId).removeClass('x-invalid').addClass('x-valid');
      return;
    } else {
      this.$(elemId).removeClass('x-valid').addClass('x-invalid');
      return "is invalid";
    }
  },

  refreshState: function(e) {
    this.state = this.checkState();
    return this;
  },

  checkState: function(e) {
    if (!this.model.get("visited")) { return "disabled"; }
    if (this.$(".x-invalid").length == 0) return "complete";
    if (this.$(".x-valid").length == 0) return "todo";
    return "incomplete";
  },

});
