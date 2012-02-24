Views.HcVisits.EditVisitInfo = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_visit_info"],

  tagName: "div",
  className: "edit-visit-info-screen",
  tabName: "tab-visit-info",
  state: "todo",

  events: {
    "change": "change",
    "change input[name='visited']": "renderChange",
    "change input[name='non_visit_reason']": "renderChange",
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template(this.model.toJSON()));

    this.validate();
    this.refreshState();

    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.remove();
    this.unbind();
  },

  validate: function() {
    var that = this;
    this.$(".validate").each(function(idx,elem) { that.validateElement(null, elem); });
  },

  validateElement: function(e, elem) {
    elem = elem || e.srcElement;
    if (!$(elem).hasClass("validate")) { return; }

    // add additional statements for special cases here

    // NOTE: currently going off model, which requires updating model first
    // as it was going to require dealing with radio/checkboxes/etc otherwise

    if (this.model.get(elem.name)) {
      this.$("#x-"+elem.name).removeClass('x-invalid').addClass('x-valid');
      return;
    } else {
      this.$("#x-"+elem.name).removeClass('x-valid').addClass('x-invalid');
      return "invalid";
    }
  },

  change: function(e) {
    e.preventDefault();
    var attrs = this.serialize();
    if (this.model.set(attrs)) {
      this.validateElement(e, e.srcElement);
    }

    this.refreshState();
  },

  renderChange: function(e) {
    this.change(e);
    this.render();
  },

  serialize: function() {
    return this.$("form").toObject({ skipEmpty: false, emptyToNull: true });
  },

  refreshState: function(e) {
    var oldState = this.state;
    this.state = this.checkState();

    return this;
  },

  checkState: function(e) {
    if (this.$(".x-invalid").length == 0) return "complete";
    if (this.$(".x-valid").length == 0) return "todo";
    return "incomplete";
  },

});
