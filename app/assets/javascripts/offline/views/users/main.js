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
    "submit": "swallowEvent",
    "click #fc-choose-button":  "selectZone",
    "click #fc-choose-link":    "showZone",
    "click #fc-show-button":    "editZone",
    "click #fc-select-hc-link": "goToSelectHc",
//  "click #fc-reset-search":   "resetSearch",
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
    $('#inner_topbar').hide();  
    return this;
  },


  close: function() {
    this.undelegateEvents();
    this.unbind();
  },

  selectZone: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var dzCode = this.$("#fc-delivery_zone").val();
    this.deliveryZone = this.deliveryZones.get(dzCode);
    this.districts = this.deliveryZone.get('districts');
    this.visitMonth = this.$("#fc-visit_month").val();
    this.screen = "zone-show";

    this.render();
  },

  editZone: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.screen = "zone-select";

    this.render();
  },

  showZone: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.searchText = null;
    this.screen = "zone-show";

    this.render();
  },

  goToSelectHc: function(e) {
    goTo(["select_hc",this.visitMonth, this.deliveryZone.get('code')].join("/"), e);
  },


  goToReports: function(e) {
    goTo('reports/generic/' + this.visitMonth + '/', e);
  },
    


//resetSearch: function(e) {
//  e.preventDefault();
//  e.stopPropagation();

//  window.rst = e;
//  this.render();
//},

  swallowEvent: function(e) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  },

});
