Views.HcVisits.Show = Views.HcVisits.Container.extend({
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

    this.readonly = true

    var that = this;

    _.each(this.SCREEN_FACTORIES, function(factory) {
      var screen = factory(options);
      var tab = that.addScreen(screen.tabName, screen);

      screen.on('change:state', function(state) {
        tab.setState(state);

        // recalculate the model's state
        var screenStates = _.values(that.hcVisit.get('screenStates', { silent: true }));
        screenStates = _.without(screenStates, 'disabled');
        var state = _.all(screenStates, function(s) { return s == 'todo' }) ? 'todo'
          : _.all(screenStates, function(s) { return s == 'complete' }) ? 'complete'
          : 'incomplete';
      });

      screen.render();
      screen.refreshState();
    });
  },

});
