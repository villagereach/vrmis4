Views.HcVisits.EditRdtInventory = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_rdt_inventory'],

  className: 'edit-rdt-inventory-screen',
  tabName: 'rdt-inventory',

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);

    this.packages = new Collections.Packages(
      options.packages.filter(function(p) {
        return p.get('product_type') == 'test';
      })
    );
  },

  refreshState: function(newState) {
    newState = this.hcVisit.get('visited') === false ? 'disabled' : newState;
    return this.super.refreshState.apply(this, [newState]);
  },

});
