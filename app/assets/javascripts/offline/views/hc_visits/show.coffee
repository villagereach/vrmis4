class Views.HcVisits.Show extends Views.HcVisits.Container
  events: _.extend(_.clone(Views.HcVisits.Container::events), {
    'click #edit-visit': -> @trigger 'navigate', "#hc_visits/#{@hcVisit.get('code')}/edit", true
  })

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

    @readonly = true
    for screen in screens
      tab = @addScreen(screen.tabName, screen)
      screen.on 'change:state', (state) => tab.setState(state)
      screen.render()
      screen.refreshState()

  render: ->
    super()
    @checkEditability()
    @

  checkEditability: ->
    $elem = @$('#edit-visit')
    $elem.hide()

    $.getJSON "#{App.baseUrl}/users/current", (user) =>
      $elem.show() if user?.role == 'admin'
