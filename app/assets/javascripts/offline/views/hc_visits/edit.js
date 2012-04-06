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

});
