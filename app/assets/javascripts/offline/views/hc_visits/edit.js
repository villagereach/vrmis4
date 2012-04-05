Views.HcVisits.Edit = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/container"],

  el: "#offline-container",

  vh: Helpers.View,
  t: Helpers.View.t,

  events: {
    "click .next-tab":   "nextTab",
    "click .prev-tab":   "prevTab",
    "click .change-hc":   "gotoMain",
  },

  initialize: function(options) {
    this.hcVisit = options.hcVisit;
    this.healthCenter = options.healthCenter;
    this.idealStock = options.idealStock;

    this.packages = options.packages;
    this.products = options.products;
    this.stockCards = options.stockCards;
    this.equipmentTypes = options.equipmentTypes;

    this.screens = [
      new Views.HcVisits.EditVisitInfo({ hcVisit: this.hcVisit }),
//    new Views.EditRefrigerators({ hcVisit: this.hcVisit }),
      new Views.HcVisits.EditEpiInventory({
        hcVisit: this.hcVisit,
        packages: this.packages,
        idealStock: this.idealStock,
      }),
      new Views.HcVisits.EditRdtInventory({
        hcVisit: this.hcVisit,
        packages: this.packages,
      }),
      new Views.HcVisits.EditEquipmentStatus({
        hcVisit: this.hcVisit,
        equipmentTypes: this.equipmentTypes,
      }),
      new Views.HcVisits.EditStockCards({
        hcVisit: this.hcVisit,
        stockCards: this.stockCards,
      }),
      new Views.HcVisits.EditRdtStock({
        hcVisit: this.hcVisit,
        packages: this.packages,
      }),
      new Views.HcVisits.EditEpiStock({
        hcVisit: this.hcVisit,
        products: this.products,
      }),
      new Views.HcVisits.EditFullVacTally({ hcVisit: this.hcVisit }),
//    new Views.HcVisits.EditChildVacTally({
//      hcVisit: this.hcVisit,
//      healthCenter: this.healthCenter,
//      packages: this.packages,
//    }),
//    new Views.HcVisits.EditAdultVacTally({
//      hcVisit: this.hcVisit,
//      healthCenter: this.healthCenter,
//      packages: this.packages,
//    }),
//    new Views.HcVisits.EditObservations({ hcVisit: this.hcVisit }),
    ];

    var that = this;
    _.each(this.screens, function(screen) {
      screen.render(); // pre-render so validations for tab states work
      screen.on('refresh:tabs', function() { that.render(); });
    });

    // select the default screen or first provided if none
    this._screenIdx = 0;
  },

  render: function() {
    this.$el.html(this.template(this));

    this.$(".tab-screen").html(this.screens[this._screenIdx].render().el);

    var that = this;
    this.tabs = _.map(this.screens, function(screen, idx) {
      tab = new Views.HcVisits.TabMenuItem({
        tabName: screen.tabName,
        selected: (idx == that._screenIdx),
        state: screen.state,
      });
      tab.on('select:tab', function() { that.selectTab(screen); });
      return tab;
    });

    this.$(".tab-menu ul").append(_.map(this.tabs, function(tab) { return tab.render().el; }));

    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();

    _.each(this.screens, function(screen) { screen.close(); });
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

    if (this.screens[newIdx].state == "disabled") { newIdx = 0; }

    this._screenIdx = newIdx;

    this.hcVisit.save();

    this.render();

    return this;
  },

  gotoMain: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.hcVisit.save();

    App.router.navigate("#home", { trigger: true });
  }

});
