Views.HcVisits.Container = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/container"],

  el: "#offline-container",

  events: {
    "click .next-tab":   "nextTab",
    "click .prev-tab":   "prevTab",
  },

  initialize: function(options) {
    this.screens = options.screens || [];

    var that = this;
    _.each(this.screens, function(screen) {
      screen.on('refresh:tabs', function() { that.render(); });
    });

    // select the default screen or first provided if none
    this._screenIdx = 0;
  },

  render: function() {
    this.$el.html(this.template(this.model.toJSON()));

    var that = this;
    var tab_list = this.$(".tab-menu ul");
    this.tabs = _.map(this.screens, function(screen, idx) {
      tab = new Views.HcVisits.TabMenuItem({
        tabName: screen.tabName,
        selected: (idx == that._screenIdx),
        state: screen.state,
      });
      tab.on('select:tab', function() { that.selectTab(screen); });
      tab_list.append(tab.render().el);
      return tab;
    });

    this.$(".tab-screen").html(this.screens[this._screenIdx].render().el);

    return this;
  },

  close: function() {
    this.undelegateEvents();
    // this.remove(); // FIXME: breaks future instances of view, why?
    this.unbind();

    _.each(this.screens, function(screen) { screen.close(); });

    // left the page, save the visit
    this.model.save();
  },

  hasPrevTab: function() {
    if (this._screenIdx - 1 < 0) { return false }
    var prev = _(this.screens).first(this._screenIdx).reverse()
      .filter(function(s) { return s.state != "disabled" })[0];

    return !!prev;
  },

  hasNextTab: function() {
    var next = _(this.screens).rest(this._screenIdx + 1)
      .filter(function(s) { return s.state != "disabled" })[0];

    return !!next;
  },

  prevTab: function(e) {
    e.preventDefault();
    e.stopPropagation();
    if (this._screenIdx - 1 < 0) { return false }
    var prev = _(this.screens).first(this._screenIdx).reverse()
      .filter(function(s) { return s.state != "disabled" })[0];

    return this.selectTab(prev);
  },

  nextTab: function(e) {
    e.preventDefault();
    e.stopPropagation();
    var next = _(this.screens).rest(this._screenIdx + 1)
      .filter(function(s) { return s.state != "disabled" })[0];

    return this.selectTab(next);
  },

  selectTab: function(screen_or_name) {
    var newIdx = _.indexOf(this.screens, screen_or_name);
    if (newIdx < 0) { newIdx = _.indexOf(_.pluck(this.screens, 'tabName'), screen_or_name) }
    if (newIdx < 0) { return this; }

    this._screenIdx = newIdx;

    this.render();

    return this;
  },

});
