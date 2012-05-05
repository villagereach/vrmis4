class Views.HcVisits.EditRefrigerators extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_refrigerators']

  className: 'edit-refrigerators-screen'
  tabName: 'refrigerators'

  events: _.extend(_.clone(Views.HcVisits.EditScreen::events), {
    'click .add-fridge': 'addFridge'
    'click .del-fridge': 'delFridge'
  })

  EMPTY_FRIDGE: { running_problems: [] }

  initialize: (options) ->
    super(options)

    unless @hcVisit.get('refrigerators', { silent: true })
      @hcVisit.set('refrigerators', [_.clone(@EMPTY_FRIDGE)], { silent: true })

  refreshState: (newState) ->
    super(if @hcVisit.get('visited') is false then 'disabled' else newState)

  addFridge: ->
    @hcVisit.add('refrigerators', _.clone(@EMPTY_FRIDGE))
    @render()
    @refreshState()

  delFridge: (e) ->
    idx = e.target.dataset.refrigeratorIdx
    @hcVisit.remove("refrigerators[#{idx}]")
    @render()
    @refreshState()
