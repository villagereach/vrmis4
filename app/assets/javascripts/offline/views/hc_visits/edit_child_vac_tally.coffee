class Views.HcVisits.EditChildVacTally extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_child_vac_tally']

  className: 'edit-child-vac-tally-screen'
  tabName: 'child-vac-tally'

  events: _.extend(_.clone(Views.HcVisits.EditScreen::events), {
    'change .calculate' : 'recalculate'
  })
    
  WASTAGE_RATES: [
    { pkgCode: 'bcg',     rows: ['bcg'] }
    { pkgCode: 'polio10', rows: ['polio0', 'polio1', 'polio2', 'polio3'] }
    { pkgCode: 'penta1',  rows: ['penta1', 'penta2', 'penta3'] }
    { pkgCode: 'measles', rows: ['measles'] }
    { pkgCode: 'pcv10', rows: ['pcv'] }
    
  ]

  render: ->
    super()
    @recalculate()
    @

  recalculate: (e, elem) ->
    if elem || e
      # called for a specific row, recalculate just that row
      baseId = '#' + $(elem || e.target).attr('id').replace(/-[^-]*(?:-nr)?$/, '')
      @recalculateRow(baseId)
    else
      for row in _.flatten(@WASTAGE_RATES.map (o) => o.rows)
        @recalculateRow("#hc_visit-child_vac_tally-#{row}")
    @

  recalculateRow: (baseId) =>
    target = baseId.match(/[^-]+$/)[0]
    baseBaseId = baseId.replace(/-[^-]*$/, '')

    targetMultiplier = @target_pcts.child[target]
    targetGroup = @healthCenter.get('population') * targetMultiplier
    @$("#{baseId}-target_group").html(Math.floor(targetGroup))

    values0_11 = [@$("#{baseId}-hc0_11").val(), @$("#{baseId}-mb0_11").val()]
    total0_11 = values0_11.reduce ((m,n) => m + (parseInt(n)||0)), 0
    @$("#{baseId}-total0_11").html(total0_11)

    coverageRate = total0_11 / targetGroup
    @$("#{baseId}-coverage_rate").html(Math.floor(100 * coverageRate) + '%')

    values12_23 = [@$("#{baseId}-hc12_23").val(), @$("#{baseId}-mb12_23").val()]
    total12_23 = values12_23.reduce ((m,n) => m + (parseInt(n)||0)), 0
    @$("#{baseId}-total12_23").html(total12_23)

    values = _.flatten([values0_11, values12_23])
    total = values.reduce ((m,n) => m + (parseInt(n)||0)), 0
    @$("#{baseId}-total").html(total)

    w = _.find(@WASTAGE_RATES, (o) => o.pkgCode == target || _.include(o.rows, target))
    if openedVials = parseInt(@$("#{baseBaseId}-#{w.pkgCode}-opened").val())
      pkgDoses = parseInt(@packages.get(w.pkgCode).get('quantity')) || 1
      totalVaccinations = _(w.rows)
        .map((row) => parseInt(@$("#{baseBaseId}-#{row}-total").text()) || 0)
        .reduce(((m,n) => m + n), 0)
      wastage = ((openedVials * pkgDoses) - totalVaccinations) / (openedVials * pkgDoses)
      @$("#{baseBaseId}-#{w.pkgCode}-wastage").html(Math.floor(100 * wastage) + '%')
    else
      @$("#{baseBaseId}-#{w.pkgCode}-wastage").html('')

    @
