class Views.HcVisits.EditVisitInfo extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_visit_info']

  className: 'edit-visit-info-screen'
  tabName: 'visit-info'

  render: ->
    super()
    @picker?.close()
    @picker = Helpers.Date.datePicker(
      '#hc_visit-visited_at',
      @hcVisit.get('month'),
      '%d/%m/%Y'
    )
    @

  close: ->
    @picker?.close()
    super()

  cleanupValue: (name, value) ->
    value = super(name, value)
    if value? && value isnt 'NR' && name.match(/^visited_at$/)
      value = @dh.reformat(value, '%d/%m/%Y', '%Y-%m-%d')
    value
