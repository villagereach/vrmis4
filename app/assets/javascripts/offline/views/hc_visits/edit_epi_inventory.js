Views.HcVisits.EditEpiInventory = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_epi_inventory'],

  className: 'edit-epi-inventory-screen',
  tabName: 'epi-inventory',

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);
    this.screenPos = 3;

    this.packages = new Collections.Packages(
      options.packages.filter(function(p) {
        return p.get('product_type') != 'test';
      })
    );
  },

});
