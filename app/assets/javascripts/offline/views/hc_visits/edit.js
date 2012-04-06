Views.HcVisits.Edit = Views.HcVisits.Container.extend({
  SCREEN_FACTORIES: [
    function(o) { return new Views.HcVisits.EditVisitInfo(o) },
    function(o) { return new Views.HcVisits.EditRefrigerators(o) },
    function(o) { return new Views.HcVisits.EditEpiInventory(o) },
    function(o) { return new Views.HcVisits.EditRdtInventory(o) },
    function(o) { return new Views.HcVisits.EditEquipmentStatus(o) },
    function(o) { return new Views.HcVisits.EditStockCards(o) },
    function(o) { return new Views.HcVisits.EditRdtStock(o) },
    function(o) { return new Views.HcVisits.EditEpiStock(o) },
    function(o) { return new Views.HcVisits.EditFullVacTally(o) },
    function(o) { return new Views.HcVisits.EditAdultVacTally(o) },
    function(o) { return new Views.HcVisits.EditObservations(o) },
  ],

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);

    var that = this;

    this.on('select:tab', function() {
      that.hcVisit.save();
    });

    _.each(this.SCREEN_FACTORIES, function(factory) {
      var screen = factory(options);
      var tab = that.addScreen(screen.tabName, screen);

      screen.on('change:state', function(state) {
        tab.setState(state);

        // recalculate the model's state
        that.hcVisit.set('screenStates.' + tab.tabName, state);
        var screenStates = _.values(that.hcVisit.get('screenStates', { silent: true }));
        screenStates = _.without(screenStates, 'disabled');
        var state = _.all(screenStates, function(s) { return s == 'todo' }) ? 'todo'
          : _.all(screenStates, function(s) { return s == 'complete' }) ? 'complete'
          : 'incomplete';
        that.hcVisit.set('state', state);
      });

      screen.render();
      screen.refreshState();
    });

    this.hcVisit.on('change:visited', function(model, visited) {
      _.each([1,2,3,4,5], function(i) {
        var screen = that.screens[i];
        screen.refreshState(!visited ? 'disabled' : null);
      });
    });
  },

  changeHC: function(e) {
    this.hcVisit.save();
    this.super.changeHC.apply(this, arguments);
  }

//render: function() {
//  this.$el.html(this.template(this));

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

//close: function() {
//  this.undelegateEvents();
//  this.unbind();

//  _.each(this.screens, function(screen) { screen.close(); });
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

//  this.hcVisit.save();

//  this.render();

//  return this;
//},


});
