class Views.Users.Main extends Backbone.View
  template: JST['offline/templates/users/fc_main']

  el: '#offline-container'
  screen: 'zone-select'
  deliveryZone: null
  visitMonth: null
  districts: []
  healthCenter: null
  searchText: null

  vh: Helpers.View
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
    @visitMonth = options.visitMonth

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
    @visitMonth = @$('#fc-visit_month').val()
    @render('zone-show')

  editZone: (e) ->
    @render('zone-select')

  showZone: (e) ->
    @searchText = null
    @render('zone-show')
