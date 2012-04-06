Views.HcVisits.Container = Backbone.View.extend({
  template: JST['offline/templates/hc_visits/container'],

  el: '#offline-container',

  events: {
//  'click .next-tab' : 'nextTab',
//  'click .prev-tab' : 'prevTab',
    'click .change-hc': 'changeHC',
  },

  vh: Helpers.View,
  t: Helpers.View.t,

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

//  var that = this;
//  _.each(this.screens, function(screen) {
//    screen.render(); // pre-render so validations for tab states work
//    screen.on('refresh:tabs', function() { that.render(); });
//  });

//  // select the default screen or first provided if none
//  this._screenIdx = 0;
//},

//render: function() {
//  this.$el.html(this.template(this.hcVisit));

//  this.$(".tab-screen").html(this.screens[this._screenIdx].render().el);

//  var that = this;
//  this.tabs = _.map(this.screens, function(screen, idx) {
//    tab = new Views.HcVisits.TabMenuItem({
//      tabName: screen.tabName,
//      selected: (idx == that._screenIdx),
//      state: screen.state,
//    });
//    tab.on('select:tab', function() { that.selectTab(screen); });
//    return tab;
//  });

//  this.$(".tab-menu ul").append(_.map(this.tabs, function(tab) { return tab.render().el; }));

//  return this;
//},

//hasPrevTab: function() {
//  if (this._screenIdx - 1 < 0) { return false }
//  var prev = _(this.screens).first(this._screenIdx).reverse()
//    .filter(function(s) { return s.state != "disabled" })[0];

//  return !!prev;
//},

//hasNextTab: function() {
//  var next = _(this.screens).rest(this._screenIdx + 1)
//    .filter(function(s) { return s.state != "disabled" })[0];

//  return !!next;
//},

//prevTab: function(e) {
//  e.preventDefault();
//  e.stopPropagation();
//  if (this._screenIdx - 1 < 0) { return false }
//  var prev = _(this.screens).first(this._screenIdx).reverse()
//    .filter(function(s) { return s.state != "disabled" })[0];

//  return this.selectTab(prev);
//},

//nextTab: function(e) {
//  e.preventDefault();
//  e.stopPropagation();
//  var next = _(this.screens).rest(this._screenIdx + 1)
//    .filter(function(s) { return s.state != "disabled" })[0];

//  return this.selectTab(next);
//},

//selectTab: function(screen_or_name) {
//  var newIdx = _.indexOf(this.screens, screen_or_name);
//  if (newIdx < 0) { newIdx = _.indexOf(_.pluck(this.screens, 'tabName'), screen_or_name) }
//  if (newIdx < 0) { return this; }

//  if (this.screens[newIdx].state == "disabled") { newIdx = 0; }

//  this._screenIdx = newIdx;

//  this.model.save();

//  this.render();

//  return this;
//},

//gotoMain: function(e) {
//  e.preventDefault();
//  e.stopPropagation();

//  this.model.save();

//  App.router.navigate("#home", { trigger: true });
//}

  setSuper: function(klass) { this.super = klass },

});

// hackish way of setting 'super' class to make subclassed functions cleaner
Views.HcVisits.Container.prototype.setSuper(Views.HcVisits.Container.prototype);

