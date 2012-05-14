class Views.Users.Main extends Backbone.View
  template: JST['offline/templates/users/fc_main']

  el: '#offline-container'
  screen: 'zone-select'
  deliveryZone: null
  month: null
  districts: []
  healthCenter: null
  searchText: null

  vh: Helpers.View
  dh: Helpers.Date
  t: Helpers.View.t

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #fc-choose-button': 'selectZone'
    'click #fc-choose-link': 'showZone'
    'click #fc-show-button': 'editZone'

  initialize: (options) ->
    @months = options.months
    @deliveryZones = options.deliveryZones
    @deliveryZoneCodes = @deliveryZones.pluck('code')
    @deliveryZone = options.deliveryZone
    @districts = @deliveryZone?.get('districts')
    @dzCode = @deliveryZone?.get('code')
    @month = options.month
    @screen = options.screen

  render: (@screen = @screen) ->
    @delegateEvents()
    @$el.html @template(@)
    @

  close: ->
    @undelegateEvents()
    @unbind()

  selectZone: (e) ->
    @dzCode = @$('#fc-delivery_zone').val()
    @deliveryZone = @deliveryZones.get(@dzCode)
    @districts = @deliveryZone.get('districts')
    @month = @$('#fc-visit_month').val()
    @render('zone-show')
    @trigger 'navigate', "#main/#{@month}/#{@dzCode}", trigger: false

  editZone: (e) ->
    @render('zone-select')
    @trigger 'navigate', "#main", trigger: false

  showZone: (e) ->
    @searchText = null
    @render('zone-show')
