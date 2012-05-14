class Views.HcVisits.EditVisitInfo extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_visit_info']

  className: 'edit-visit-info-screen'
  tabName: 'visit-info'

  cleanupValue: (name, value) ->
    value = super(name, value)
    if value? && value isnt 'NR' && name.match(/^visited_at$/)
      value = @dh.reformat(value, '%d/%m/%Y', '%Y-%m-%d')
    value
