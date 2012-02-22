Views.Users.Main = Backbone.View.extend({
  template: JST["offline/templates/users/fc_main"],

  el: "#offline-container",
  screen: "zone-select",
  deliveryZone: null,
  visitMonth: null,

  events: {
    "click #fc-choose-button": "selectZone",
    "click #fc-show-button":   "editZone",
  },

  initialize: function(options) {
    this.deliveryZones = options.deliveryZones;
    this.months = options.months;
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template({
      screen: this.screen,
      deliveryZone: this.deliveryZone,
      visitMonth: this.visitMonth,
      deliveryZoneCodes: this.deliveryZones.pluck('code'),
      months: this.months,
    }));

    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
  },

  selectZone: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.deliveryZone = this.$("#fc-delivery_zone").val();
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

});
