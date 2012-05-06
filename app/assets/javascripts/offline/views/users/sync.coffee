class Views.Users.Sync extends Backbone.View
  template: JST['offline/templates/users/sync']

  el: '#offline-container'
  pullResults:
    products: 'unknown'
    deliveryZones: 'unknown'
    healthCenters: 'unknown'
    hcVisits: 'unknown'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #sync-pull': 'pullData'
    'click #sync-push': 'pushData'
    'click #check-online': 'checkOnline'

  initialize: (options) ->
    App.dirtyHcVisits.fetch success: => @render()

  render: ->
    states = App.dirtyHcVisits.map (v) => v.get('state')
    dirtyCounts = _.reduce states, (counts, state) =>
        counts.total = (counts.total || 0) + 1
        counts[state] = (counts[state] || 0) + 1
        counts
      , {}

    @$el.html(@template(
      pullResults: this.pullResults,
      dirtyCounts: { hcVisits: dirtyCounts.complete || 0 },
    ))

    @checkOnline()

    @

  close: ->
    @undelegateEvents()
    this.unbind()

  pullData: ->
    @pullResults = @model.pull()
    @pullResults.on('pulled:products pulled:deliveryZones pulled:healthCenters pulled:hcVisits', @render, @)

  pushData: ->
    @pushResults = @model.push()
    @pushResults.on('pushed:hcVisit', @render, @)

  checkOnline: ->
    $elem = @$('#online-status')
    $elem.removeClass('online').removeClass('offline')
    $elem.children('.message').text 'Checking online status...'

    $.ajax
      url: "#{App.baseUrl}/ping",
      success: => $elem.addClass('online').children('.message').text('ONLINE')
      error: => $elem.addClass('offline').children('.message').text('OFFLINE')
