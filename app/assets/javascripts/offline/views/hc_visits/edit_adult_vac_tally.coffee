class Views.HcVisits.EditAdultVacTally extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_adult_vac_tally']

  className: 'edit-adult-vac-tally-screen'
  tabName: 'adult-vac-tally'

  events: _.extend(_.clone(Views.HcVisits.EditScreen::events), {
    'change .calculate' : 'recalculate'
  })



  WASTAGE_RATES: [
    {
      pkgCode: 'tetanus'
      rows: [ 'w_pregnant', 'w_15_49_community', 'w_15_49_student',
              'w_15_49_labor', 'student', 'labor', 'other' ]
    }
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
        @recalculateRow("#hc_visit-adult_vac_tally-#{row}")
    @

  recalculateRow: (baseId) ->
    target = baseId.match(/[^-]+$/)[0]
    baseBaseId = baseId.replace(/-[^-]*$/, '')

    if _.include(_.keys(@target_pcts.adult), target) 
      targetGroup = @healthCenter.get('population') * @target_pcts.adult[target]
      @$("#{baseId}-target_group").html(Math.floor(targetGroup))


    values1 = [@$("#{baseId}-tet1hc").val(), @$("#{baseId}-tet1mb").val()]
    total1 = values1.reduce ((m,n) => m + (parseInt(n)||0)), 0
    @$("#{baseId}-tet1total").html(total1)

    values2_5 = [@$("#{baseId}-tet2_5hc").val(), @$("#{baseId}-tet2_5mb").val()]
    total2_5 = values2_5.reduce ((m,n) => m + (parseInt(n)||0)), 0
    @$("#{baseId}-tet2_5total").html(total2_5)

    values = _.flatten([values1, values2_5])
    total = values.reduce ((m,n) => m + (parseInt(n)||0)), 0
    @$("#{baseId}-total").html(total)

    coverageRate = total1 / targetGroup if target is 'w_pregnant'
    coverageRate ?= (total1 + total2_5) / targetGroup

    @$("#{baseId}-coverage_rate").html(Math.floor(100 * coverageRate) + '%')

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

    # totals across bottom of screen
    tet1hc = _(w.rows)
      .map((row) => parseInt(@$("#{baseBaseId}-#{row}-tet1hc").val()) || 0)
      .reduce(((m,n) => m + n), 0)
    @$("#{baseBaseId}-tet1hc-total").html(tet1hc)

    tet1mb = _(w.rows)
      .map((row) => parseInt(@$("#{baseBaseId}-#{row}-tet1mb").val()) || 0)
      .reduce(((m,n) => m + n), 0)
    @$("#{baseBaseId}-tet1mb-total").html(tet1mb)

    tet1total = tet1hc + tet1mb
    @$("#{baseBaseId}-tet1total-total").html(tet1total)

    tet2_5hc = _(w.rows)
      .map((row) => parseInt(@$("#{baseBaseId}-#{row}-tet2_5hc").val()) || 0)
      .reduce(((m,n) => m + n), 0)
    @$("#{baseBaseId}-tet2_5hc-total").html(tet2_5hc)

    tet2_5mb = _(w.rows)
      .map((row) => parseInt(@$("#{baseBaseId}-#{row}-tet2_5mb").val()) || 0)
      .reduce(((m,n) => m + n), 0)
    @$("#{baseBaseId}-tet2_5mb-total").html(tet2_5mb)

    tet2_5total = tet2_5hc + tet2_5mb
    @$("#{baseBaseId}-tet2_5total-total").html(tet2_5total)

    @$("#{baseBaseId}-total-total").html(tet1total + tet2_5total)

    @
