Views.HcVisits.Container = Backbone.View.extend({
  template: JST['offline/templates/hc_visits/container'],

  el: '#offline-container',

  events: {
    "click .change-hc":   "goToSelectHc",
  },
  vh: Helpers.View,
  t: Helpers.View.t,

  goToSelectHc: function(e) { 
    dzCode = this.hcVisit.get('delivery_zone_code');
    month = this.hcVisit.get('month');
    goTo(['select_hc',month,dzCode].join("/"), e);
  },
 
  initialize: function(options) {
    var that = this;
    _.each(options, function(v,k) { that[k] = v });

    this.tabs = [];
    this.screens = [];
    this.screenIdx = -1;
    this.currentTab = null;

    this.on('select:tab', this.selectTab);
  },

  render: function() {
    this.$el.html(this.template(this));

    this.$(".tab-menu ul").append(_.map(this.tabs, function(tab) { return tab.render().el; }));
    this.selectTab(this.currentTab);

    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();

    _.each(this.screens, function(screen) { screen.close(); });
    _.each(this.tabs, function(tab) { tab.close(); });
  },

  addScreen: function(tabName, screen) {
    var tab = new Views.HcVisits.TabMenuItem({
      tabName: screen.tabName,
      state: screen.state,
    });

    var that = this;
    tab.on('all', function() { that.trigger.apply(that, arguments) });

    var pos = this.tabs.push(tab);
    screen.screenPos = pos;
    this.screens.push(screen);

    if (!this.currentTab) {
      this.currentTab = tabName;
      this.screenIdx = pos - 1;
      tab.selected = true;
    }

    return tab;
  },

  selectTab: function(tabName) {
    if (tabName != this.currentTab) {
      this.tabs[this.screenIdx].deselect();
      var i;
      for (i = 0; i < this.tabs.length; i++) {
        if (this.tabs[i].tabName != tabName) { continue; }
        this.tabs[i].select();
        this.currentTab = tabName;
        this.screenIdx = i;
        break;
      }
    }

    if (this.screenIdx >= 0) {
      this.$('.tab-screen').html(this.screens[this.screenIdx].render().el);
    }
  },

  hasPrevTab: function() {
    return true;
  },

  hasNextTab: function() {
    return true;
  },

  changeHC: function(e) {
    e.preventDefault();
    dzCode = this.hcVisit.get('delivery_zone_code');
    month = this.hcVisit.get('month');
    goTo(['select_hc',month,dzCode].join('/'), e);
  },

  setSuper: function(klass) { this.super = klass },

});

// hackish way of setting 'super' class to make subclassed functions cleaner
Views.HcVisits.Container.prototype.setSuper(Views.HcVisits.Container.prototype);

