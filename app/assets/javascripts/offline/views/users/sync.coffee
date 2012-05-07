class Views.Users.Sync extends Backbone.View
  template: JST['offline/templates/users/sync']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #sync-pull': 'pullData'
    'click #sync-push': 'pushData'
    'click #check-online': 'checkOnline'

  pullResults:
    products:        'unknown'
    deliveryZones:   'unknown'
    healthCenters:   'unknown'
    warehouses:      'unknown'
    hcVisits:        'unknown'
    warehouseVisits: 'unknown'

  render: ->
    hcvStates = App.dirtyHcVisits.map (v) => v.get('state')
    hcvDirtyCounts = _.reduce hcvStates, (counts, state) =>
        counts.total = (counts.total || 0) + 1
        counts[state] = (counts[state] || 0) + 1
        counts
      , {}

    wvStates = App.dirtyHcVisits.map (v) => v.get('state')
    wvDirtyCounts = _.reduce wvStates, (counts, state) =>
        counts.total = (counts.total || 0) + 1
        counts[state] = (counts[state] || 0) + 1
        counts
      , {}

    @$el.html(@template(
      pullResults: @pullResults,
      dirtyCounts:
        hcVisits: hcvDirtyCounts.complete || 0
        warehouseVisits: wvDirtyCounts.complete || 0
    ))

    @checkOnline()

    @

  close: ->
    @undelegateEvents()
    this.unbind()

  pullData: ->
    @render()
    @pullResults = @model.pull()
    @pullResults.on 'pulled:products pulled:deliveryZones pulled:healthCenters pulled:warehouses pulled:hcVisits pulled:warehouseVisits', =>
      @model.save()
      @render()

  pushData: ->
    @pushResults = @model.push()
    @pushResults.on 'pushed:hcVisit pushed:warehouseVisit', =>
      @model.save()
      @render()

  checkOnline: ->
    $elem = @$('#online-status')
    $elem.removeClass('online').removeClass('offline')
    $elem.children('.message').text 'Checking online status...'

    $.ajax
      url: "#{App.baseUrl}/ping",
      success: => $elem.addClass('online').children('.message').text('ONLINE')
      error: => $elem.addClass('offline').children('.message').text('OFFLINE')
