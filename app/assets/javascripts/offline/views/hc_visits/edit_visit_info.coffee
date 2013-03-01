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

  validateElement: (elem, value, isValid = null) ->
    if elem.name.match(/^visited_at$/)
      # date ranges allowed for visited_at date
      pMonth = @dh.parse(@hcVisit.get('month'))
      min = new Date(pMonth.year, (pMonth.month-1) - 1, 15) # 15th of prev month
      max = new Date(pMonth.year, (pMonth.month-1) + 1, 15) # 15th of next month

      pVisitedAt = @dh.parse(value)
      current = new Date(pVisitedAt.year, (pVisitedAt.month-1), pVisitedAt.day)
      isValid ?= false if current < min or current > max

    super(elem, value, isValid)
