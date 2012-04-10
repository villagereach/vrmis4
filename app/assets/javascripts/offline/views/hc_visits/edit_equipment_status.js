Views.HcVisits.EditEquipmentStatus = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_equipment_status'],

  className: 'edit-equipment-status',
  tabName: 'equipment-status',

  refreshState: function(newState) {
    newState = this.hcVisit.get('visited') === false ? 'disabled' : newState;
    return this.super.refreshState.apply(this, [newState]);
  },

});
