Views.WarehouseVisits.Ideal = Backbone.View.extend({
  template: JST['offline/templates/warehouse_visits/ideal'],

  el: '#offline-container',

  vh: Helpers.View,
  t: Helpers.View.t,

  initialize: function(options) {
    this.month = options.month;
    this.deliveryZone = options.deliveryZone;
    this.districts = this.deliveryZone.get('districts');

    this.productTypes = ['vaccine','syringe','test','safety','fuel'];
    this.pkgsByType = options.packages.groupBy(function(p) { return p.get('product_type') });
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template(this));
    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
    return this;
  },

});
