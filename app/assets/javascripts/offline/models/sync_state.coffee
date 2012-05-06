class Models.SyncState extends Backbone.Model
  database: provinceDb
  storeName: 'sync_states'

  defaults:
    syncedAt: {}
    hcVisitMonths: []

  initialize: (options) ->
    @baseUrl = options.baseUrl
    @reqMonths = options.hcVisitMonths || []

  pull: ->
    monthsToSync = _.union(@get('hcVisitMonths'), @reqMonths).sort()

    syncStatus =
      models: ['products', 'deliveryZones', 'healthCenters', 'hcVisits']
      products: 'pending'
      deliveryZones: 'pending'
      healthCenters: 'pending'
      hcVisits: 'pending'
      synced: false
    _.extend(syncStatus, Backbone.Events)

    # products and packages
    prodParams = { since: this.get('syncedAt').products }
    $.getJSON "#{@baseUrl}/products.json", prodParams, (data) =>
      App.products.rebuild(data['products'])
      App.packages.rebuild(data['packages'])
      App.stockCards.rebuild(data['stock_cards'])
      App.equipmentTypes.rebuild(data['equipment_types'])

      @set('syncedAt', _.extend(@get('syncedAt'), { products: data['synced_at'] }))
      syncStatus.products = 'synced'
      syncStatus.trigger('pulled:products')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    # delivery zones and districts
    dzParams = { since: @get('syncedAt').deliveryZones }
    $.getJSON "#{@baseUrl}/delivery_zones.json", dzParams, (data) =>
      App.deliveryZones.rebuild(data['delivery_zones'])
      App.districts.rebuild(data['districts'])

      @set('syncedAt', _.extend(@get('syncedAt'), { deliveryZones: data['synced_at'] }))
      syncStatus.deliveryZones = 'synced'
      syncStatus.trigger('pulled:deliveryZones')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    # health centers
    hcParams = { since: this.get('syncedAt').healthCenters }
    $.getJSON "#{@baseUrl}/health_centers.json", hcParams, (data) =>
      App.healthCenters.rebuild(data['health_centers'])

      @set('syncedAt', _.extend(@get('syncedAt'), { healthCenters: data['synced_at'] }))
      syncStatus.healthCenters = 'synced'
      syncStatus.trigger('pulled:healthCenters')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    # health center visits
    hcvParams = { since: this.get('syncedAt').hcVisits, months: monthsToSync.join(',') }
    $.getJSON "#{@baseUrl}/hc_visits.json", hcvParams, (data) =>
      App.hcVisits.rebuild(data['hc_visits'])

      @set('syncedAt', _.extend(@get('syncedAt'), { hcVisits: data['synced_at'] }))
      @set('hcVisitMonths', monthsToSync)
      syncStatus.hcVisits = 'synced'
      syncStatus.trigger('pulled:hcVisits')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    syncStatus

  push: ->
    syncStatus =
      hcVisits: App.dirtyHcVisits.length,
    _.extend(syncStatus, Backbone.Events)

    completed = App.dirtyHcVisits.filter (hcv) => hcv.get('state') == 'complete'
    for hcv in completed
      url = "#{@baseUrl}/hc_visits/#{hcv.get('code')}.json"
      $.post url, { code: hcv.get('code'), data: hcv.toJSON() }, (data) =>
        if data && data.result == 'success'
          window.console.log "pushed hcv for #{hcv.get('code')}"
          App.dirtyHcVisits.remove(hcv)
          hcv.destroy()
          syncStatus.hcVisits -= 1
          syncStatus.trigger('pushed:hcVisit')
          syncStatus.trigger('pushed:hcVisits') if syncStatus.hcVisits is 0
        else
          window.console.error "hcv push error: #{JSON.stringify(data)}"

    syncStatus
