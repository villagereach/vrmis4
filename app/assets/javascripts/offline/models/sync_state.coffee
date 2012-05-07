class Models.SyncState extends Backbone.NestedModel
  database: provinceDb
  storeName: 'sync_states'

  defaults:
    syncedAt: {}
    hcVisitMonths: []
    warehouseVisitMonths: []

  initialize: (options) ->
    @baseUrl = options.baseUrl
    @reqMonths = options.months || []

  pull: ->
    hcvExistingMonths = @get('hcVisitMonths', { silent: true })
    hcvNewMonths = _.difference(@reqMonths, hcvExistingMonths)

    wvExistingMonths = @get('warehouseVisitMonths', { slient: true })
    wvNewMonths = _.difference(@reqMonths, wvExistingMonths)

    syncStatus =
      models: ['products', 'deliveryZones', 'healthCenters', 'warehouses', 'hcVisits', 'warehouseVisits']
      products: 'pending'
      deliveryZones: 'pending'
      healthCenters: 'pending'
      warehouses: 'pending'
      hcVisits: 'pending'
      warehouseVisits: 'pending'
      synced: false
    _.extend(syncStatus, Backbone.Events)

    syncStatus.on 'pulled:all', =>
      @save()

    # products and packages
    prodParams = { since: @get('syncedAt.products') }
    $.getJSON "#{@baseUrl}/products.json", prodParams, (data) =>
      App.products.rebuild(data['products'])
      App.packages.rebuild(data['packages'])
      App.stockCards.rebuild(data['stock_cards'])
      App.equipmentTypes.rebuild(data['equipment_types'])

      @set 'syncedAt.products', data['synced_at']
      syncStatus.products = 'synced'
      syncStatus.trigger('pulled:products')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    # delivery zones and districts
    dzParams = { since: @get('syncedAt.deliveryZones') }
    $.getJSON "#{@baseUrl}/delivery_zones.json", dzParams, (data) =>
      App.deliveryZones.rebuild(data['delivery_zones'])
      App.districts.rebuild(data['districts'])

      @set 'syncedAt.deliveryZones', data['synced_at']
      syncStatus.deliveryZones = 'synced'
      syncStatus.trigger('pulled:deliveryZones')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    # health centers
    hcParams = { since: @get('syncedAt.healthCenters') }
    $.getJSON "#{@baseUrl}/health_centers.json", hcParams, (data) =>
      App.healthCenters.rebuild(data['health_centers'])

      @set 'syncedAt.healthCenters', data['synced_at']
      syncStatus.healthCenters = 'synced'
      syncStatus.trigger('pulled:healthCenters')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    # warehouses
    hcParams = { since: @get('syncedAt.warehouses') }
    $.getJSON "#{@baseUrl}/warehouses.json", hcParams, (data) =>
      App.warehouses.rebuild(data['warehouses'])

      @set 'syncedAt.warehouses', data['synced_at']
      syncStatus.warehouses = 'synced'
      syncStatus.trigger('pulled:warehouses')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    # health center visits
    hcvParams = { since: @get('syncedAt.hcVisits'), months: hcvExistingMonths.join(',') }
    $.getJSON "#{@baseUrl}/hc_visits.json", hcvParams, (data) =>
      App.hcVisits.rebuild(data['hc_visits'])
      @set 'syncedAt.hcVisits', data['synced_at']

      window.console.log "hcvNewMonths: #{JSON.stringify(hcvNewMonths)}"
      if hcvNewMonths.length > 0
        $.getJSON "#{@baseUrl}/hc_visits.json", { months: hcvNewMonths.join(',') }, (data) =>
          App.hcVisits.rebuild(data['hc_visits'])
          @set 'hcVisitMonths', _.union(hcvExistingMonths, hcvNewMonths).sort().reverse()
          syncStatus.hcVisits = 'synced'
          syncStatus.trigger('pulled:hcVisits')
          if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
            syncStatus.synced = true
            syncStatus.trigger('pulled:all')
      else
        syncStatus.hcVisits = 'synced'
        syncStatus.trigger('pulled:hcVisits')
        if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
          syncStatus.synced = true
          syncStatus.trigger('pulled:all')

    # warehouse visits
    wvParams = { since: @get('syncedAt.warehouseVisits'), months: wvExistingMonths.join(',') }
    $.getJSON "#{@baseUrl}/warehouse_visits.json", wvParams, (data) =>
      App.warehouseVisits.rebuild(data['warehouse_visits'])
      @set 'syncedAt.warehouseVisits', data['synced_at']

      window.console.log "wvNewMonths: #{JSON.stringify(wvNewMonths)}"
      if wvNewMonths.length > 0
        $.getJSON "#{@baseUrl}/warehouse_visits.json", { months: wvNewMonths.join(',') }, (data) =>
          App.warehouseVisits.rebuild(data['warehouse_visits'])
          @set 'warehouseVisitMonths', _.union(wvExistingMonths, wvNewMonths).sort().reverse()
          syncStatus.warehouseVisits = 'synced'
          syncStatus.trigger('pulled:warehouseVisits')
          if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
            syncStatus.synced = true
            syncStatus.trigger('pulled:all')
      else
        syncStatus.warehouseVisits = 'synced'
        syncStatus.trigger('pulled:warehouseVisits')
        if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
          syncStatus.synced = true
          syncStatus.trigger('pulled:all')

    syncStatus

  push: ->
    completedHcvs = App.dirtyHcVisits.filter (hcv) => hcv.get('state') == 'complete'
    completedWvs = App.dirtyWarehouseVisits.filter (wv) => wv.get('state') == 'complete'

    syncStatus =
      hcVisits: completedHcvs.length
      warehouseVisits: completedWvs.length
    _.extend(syncStatus, Backbone.Events)

    for hcv in completedHcvs
      url = "#{@baseUrl}/hc_visits/#{hcv.get('code')}.json"
      $.ajax
        url: url
        type: 'POST'
        username: App.province
        password: App.accessCode
        dataType: 'json'
        data:
          code: hcv.get('code')
          data: hcv.toJSON()
        success: (data) =>
          if data && data.result == 'success'
            window.console.log "pushed hcv for #{hcv.get('code')}"
            App.dirtyHcVisits.remove(hcv)
            hcv.destroy()
            syncStatus.hcVisits -= 1
            syncStatus.trigger('pushed:hcVisit')
            syncStatus.trigger('pushed:hcVisits') if syncStatus.hcVisits is 0
            if syncStatus.hcVisits is 0 and syncStatus.warehouseVisits is 0
              syncStatus.trigger('pushed:all')
          else
            window.console.error "hcv push error: #{JSON.stringify(data)}"

    for wv in completedWvs
      url = "#{@baseUrl}/warehouse_visits/#{wv.get('code')}.json"
      $.ajax
        url: url
        type: 'POST'
        username: App.province
        password: App.accessCode
        dataType: 'json'
        data:
          code: wv.get('code')
          data: wv.toJSON()
        success: (data) =>
          if data && data.result == 'success'
            window.console.log "pushed wv for #{wv.get('code')}"
            App.dirtyWarehouseVisits.remove(wv)
            wv.destroy()
            syncStatus.warehouseVisits -= 1
            syncStatus.trigger('pushed:warehouseVisit')
            syncStatus.trigger('pushed:warehouseVisits') if syncStatus.warehouseVisits is 0
            if syncStatus.hcVisits is 0 and syncStatus.warehouseVisits is 0
              syncStatus.trigger('pushed:all')
          else
            window.console.error "warehouse visit push error: #{JSON.stringify(data)}"

    syncStatus
