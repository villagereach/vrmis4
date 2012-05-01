Views.Users.Main = Backbone.View.extend({
  template: JST["offline/templates/users/fc_main"],

  el: "#offline-container",
  screen: "zone-select",
  deliveryZone: null,
  visitMonth: null,
  districts: [],
  healthCenter: null,
  searchText: null,

  vh: Helpers.View,
  t: Helpers.View.t,

  events: {
    'submit': function() { return false; }, // swallow
    'click a, button': function() { return false; }, // swallow
    "click #fc-choose-button":  "selectZone",
    "click #fc-choose-link":    "showZone",
    "click #fc-show-button":    "editZone",
    "click #before-warehouse-visit-link": "goToWarehouseIdeal",
    "click #after-warehouse-visit-link": "goToWarehouseEdit",
    "click #fc-select-hc-link": "goToSelectHc",
    "click #upload-data-link": "goToSync",
    "click #review-results-link": "goToReports",
  },

  initialize: function(options) {
    this.months = options.months;
    this.deliveryZones = options.deliveryZones;
    this.deliveryZoneCodes = this.deliveryZones.pluck('code');

    if (options.deliveryZone) { this.deliveryZone = options.deliveryZone; }
    if (options.visitMonth) { this.visitMonth = options.visitMonth; }
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template({
      screen: this.screen,
      months: this.months,
      visitMonth: this.visitMonth,
      deliveryZone: (this.deliveryZone ? this.deliveryZone.get('code') : {}),
      deliveryZoneCodes: this.deliveryZoneCodes,
      vh: this.vh,
      t: this.t,
    }));
    return this;
  },


  close: function() {
    this.undelegateEvents();
    this.unbind();
  },

  selectZone: function(e) {
    var dzCode = this.$("#fc-delivery_zone").val();
    this.deliveryZone = this.deliveryZones.get(dzCode);
    this.districts = this.deliveryZone.get('districts');
    this.visitMonth = this.$("#fc-visit_month").val();
    this.screen = "zone-show";

    this.render();
  },

  editZone: function(e) {
    this.screen = "zone-select";

    this.render();
  },

  showZone: function(e) {
    this.searchText = null;
    this.screen = "zone-show";

    this.render();
  },

  goToWarehouseIdeal: function(e) {
    var dzCode = this.deliveryZone.get('code');
    this.trigger('navigate', "warehouse_visits/"+this.visitMonth+"/"+dzCode+"/ideal", true);
  },

  goToWarehouseEdit: function(e) {
    var dzCode = this.deliveryZone.get('code');
    this.trigger('navigate', "warehouse_visits/"+this.visitMonth+"/"+dzCode, true);
  },

  goToSelectHc: function(e) {
    this.trigger('navigate', ["select_hc",this.visitMonth, this.deliveryZone.get('code')].join("/"), true);
  },

  goToReports: function(e) {
    this.trigger('navigate', 'reports/summary/' + this.visitMonth + '/', true);
  },

  goToSync: function(e) {
    this.trigger('navigate', 'sync', true);
  },

});
