class Views.HcVisits.Edit extends Views.HcVisits.Container
  initialize: (options) ->
    super(options)

    screens = [
      new Views.HcVisits.EditVisitInfo(options)
      new Views.HcVisits.EditRefrigerators(options)
      new Views.HcVisits.EditEpiInventory(options)
      new Views.HcVisits.EditRdtInventory(options)
      new Views.HcVisits.EditEquipmentStatus(options)
      new Views.HcVisits.EditStockCards(options)
      new Views.HcVisits.EditRdtStock(options)
      new Views.HcVisits.EditEpiStock(options)
      new Views.HcVisits.EditFullVacTally(options)
      new Views.HcVisits.EditChildVacTally(options)
      new Views.HcVisits.EditAdultVacTally(options)
      new Views.HcVisits.EditObservations(options)
    ]

    @on 'select:tab', => @hcVisit.save()
    @on 'click .change-hc a', => @hcVisit.save()

    screens.forEach (screen) =>
      tab = @addScreen(screen.tabName, screen)

      screen.on 'change:state', (state) ->
        tab.setState(state)

        # recalculate the model's state
        @hcVisit.set("screenStates.#{tab.tabName}", state)
        screenStates = _.values(@hcVisit.get('screenStates', { silent: true }))
        screenStates = _.without(screenStates, 'disabled')

        state = 'todo' if _.all(screenStates, (s) -> s is 'todo')
        state ?= 'complete' if _.all(screenStates, (s) -> s is 'complete')
        state ?= 'incomplete'
        @hcVisit.set('state', state)

      screen.render()
      screen.refreshState()

    @hcVisit.on 'change:visited', (model, visited) =>
      screen.refreshState() for screen in screens
      @render()
