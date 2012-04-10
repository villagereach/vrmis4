Views.HcVisits.EditRdtStock = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_rdt_stock'],

  className: 'edit-rdt-stock-screen',
  tabName: 'rdt-stock',

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);
    this.screenPos = 7;

    this.packages = new Collections.Packages(
      options.packages.filter(function(p) {
        return p.get('product_type') == 'test'
      })
    );
  },

});
