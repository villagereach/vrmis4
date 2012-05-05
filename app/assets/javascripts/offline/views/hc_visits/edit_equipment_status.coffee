class Views.HcVisits.EditEquipmentStatus extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_equipment_status']

  className: 'edit-equipment-status'
  tabName: 'equipment-status'

  refreshState: (newState) ->
    super(if @hcVisit.get('visited') is false then 'disabled' else newState)
