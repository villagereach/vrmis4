Views.HcVisits.TabMenuItem = Backbone.View.extend({
  template: JST['offline/templates/hc_visits/tab_menu_item'],

  tagName: 'li',
  className: 'tab-menu-item',

  vh: Helpers.View,
  t: Helpers.View.t,

  events: {
    'click .select-tab': 'triggerSelect',
  },

  initialize: function(options) {
    this.selected = options.selected;
    this.tabName = options.tabName;
    this.state = options.state;
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template(this));
    this.$el.addClass(this.state);
    if (this.selected) { this.$el.addClass('selected'); }
    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
  },

  triggerSelect: function(e) {
    e.preventDefault();
    this.trigger('select:tab', this.tabName);
  },

  select: function(e) {
    this.selected = true;
    this.$el.addClass('selected');
  },

  deselect: function() {
    this.selected = false;
    this.$el.removeClass('selected');
  },

  setState: function(state) {
    this.$el.removeClass(this.state).addClass(state);
    this.state = state;
  },

  disabled: function() {
    return this.state == 'disabled';
  }

});
