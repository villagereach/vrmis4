class Views.Sync.Pull extends Backbone.View
  template: JST['offline/templates/sync/pull']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #pull-data': 'pullData'

  pullResults:
    products:        'unknown'
    deliveryZones:   'unknown'
    healthCenters:   'unknown'
    warehouses:      'unknown'
    hcVisits:        'unknown'
    warehouseVisits: 'unknown'

  initialize: (options) ->
    @[k] = v for k,v of options

  render: ->
    @$el.html @template(@)
    @

  pullData: ->
    @render()
    @pullResults = @syncState.pull()
    @pullResults.on 'pulled:products pulled:deliveryZones pulled:healthCenters pulled:warehouses pulled:hcVisits pulled:warehouseVisits', =>
      @syncState.save()
      @render()
