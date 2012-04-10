Views.HcVisits.EditEquipmentStatus = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_equipment_status'],

  className: 'edit-equipment-status',
  tabName: 'equipment-status',

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);
    this.screenPos = 5;
  },

});
