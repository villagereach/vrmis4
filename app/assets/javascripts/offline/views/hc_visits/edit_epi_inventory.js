Views.HcVisits.EditEpiInventory = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_epi_inventory"],

  tagName: "div",
  className: "edit-epi-inventory-screen",
  tabName: "tab-epi-inventory",
  state: "todo",

  events: {
    "change": "change",
  },

  initialize: function() {
    var that = this;
    this.model.on('change:visited', function() {
      that.refreshState();
      that.trigger('refresh:tabs');
    });
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template());
    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.remove();
    this.unbind();
  },

  change: function(e) {
    e.preventDefault();
    var attrs = this.serialize();
    if (this.model.set('epi_inventory', attrs)) {
      this.render();
    }
  },

  serialize: function() {
    return this.$("form").toObject({ skipEmpty: false, emptyToNull: true });
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
