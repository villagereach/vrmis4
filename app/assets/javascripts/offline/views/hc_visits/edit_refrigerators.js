Views.HcVisits.EditRefrigerators = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_refrigerators"],

  tagName: "div",
  className: "edit-refrigerators-screen",
  tabName: "tab-refrigerators",
  state: "todo",

  events: {
    "change": "change",
    "change .rerender": "renderChange",
    "click .add-refrigerator": "addRefrigerator",
    "click .delete-refrigerator": "deleteRefrigerator",
  },

  initialize: function() {
    // if never been a refrigerator then let's start with a blank one
    if (!this.model.get('refrigerators')) { this.model.set('refrigerators', [{}]); }

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
      refrigerators: (this.model.get('refrigerators') || []),
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

  change: function(e, elem) {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }

    elem = elem || e.srcElement;

    var attrs = this.serialize();
    this.model.set('refrigerators', attrs.refrigerators);

    this.validateElement(e, elem);
    this.refreshState();
  },

  renderChange: function(e, elem) {
    this.change(e, elem);
    this.render();
  },

  addRefrigerator: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var refrigerators = this.model.get('refrigerators');
    refrigerators.push({});
    this.model.set('refrigerators', refrigerators);

    this.refreshState();
    this.render();
  },

  deleteRefrigerator: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var elem = e.srcElement

    var idx = $(elem).attr('data-refrigerator-idx');
    var refrigerators = this.model.get('refrigerators');
    if (!refrigerators[idx]) { return; }

    refrigerators.splice(idx, 1);
    this.model.set('refrigerators', refrigerators);

    this.refreshState();
    this.render();
  },

  serialize: function() {
    var attrs = this.$("form").toObject({ skipEmpty: false, emptyToNull: true });

    // remove nulls from refrigerators[*].running_problems[]
    _.each(attrs.refrigerators, function(r) {
      r.running_problems = _.without(r.running_problems, null);
    });

    return attrs;
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

    var value = this.model.deepGet(elem.name);
    if (value instanceof Array ? value.length > 0 : value) {
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
