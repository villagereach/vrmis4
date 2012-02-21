Views.HcVisits.TabMenuItem = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/tab_menu_item"],

  tagName: "li",
  className: "tab-menu-item",

  events: {
    "click .select-tab": "select",
  },

  initialize: function(options) {
    this.selected = options.selected;
    this.tabName = options.tabName;
    this.state = options.state;
  },

  render: function() {
    this.$el.html(this.template(this));
    this.$el.addClass(this.state);
    if (this.selected) { this.$el.addClass("selected"); }
    return this;
  },

  select: function() {
    this.trigger("select:tab");
    return this;
  },

  disabled: function() {
    return this.state == 'disabled';
  }

});
