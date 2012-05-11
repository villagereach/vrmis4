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

  checkOnline: (options = {}) ->
    $.ajax
      url: "#{App.baseUrl}/ping",
      success: => options.success() if options.success
      error: => options.error() if options.error

  pull: ->
    hcvExistingMonths = @get('hcVisitMonths', { silent: true })
    hcvNewMonths = _.difference(@reqMonths, hcvExistingMonths)

    wvExistingMonths = @get('warehouseVisitMonths', { slient: true })
    wvNewMonths = _.difference(@reqMonths, wvExistingMonths)

    syncStatus =
      models: ['snapshots', 'hcVisits', 'warehouseVisits']
      snapshots: 'pending'
      hcVisits: 'pending'
      warehouseVisits: 'pending'
      synced: false
    _.extend(syncStatus, Backbone.Events)

    syncStatus.on 'pulled:all', =>
      @save()

    $.getJSON "#{@baseUrl}/snapshots.json", since: @get('syncedAt.snapshots'), (data) =>
      if snapshot = data['snapshots'][0]
        App.deliveryZones.rebuild(snapshot['delivery_zones'])
        App.districts.rebuild(snapshot['districts'])
        App.products.rebuild(snapshot['products'])
        App.packages.rebuild(snapshot['packages'])
        App.stockCards.rebuild(snapshot['stock_cards'])
        App.equipmentTypes.rebuild(snapshot['equipment_types'])
        App.healthCenters.rebuild(snapshot['health_centers'])
        App.warehouses.rebuild(snapshot['warehouses'])
        @set('syncedAt.snapshots', data['synced_at'])

      syncStatus.snapshots = 'synced'
      syncStatus.trigger('pulled:snapshots')
      if _.all(syncStatus.models, (k) => syncStatus[k] == 'synced')
        syncStatus.synced = true
        syncStatus.trigger('pulled:all')

    # health center visits
    hcvParams = { since: @get('syncedAt.hcVisits'), months: hcvExistingMonths.join(',') }
    $.getJSON "#{@baseUrl}/hc_visits.json", hcvParams, (data) =>
      App.hcVisits.rebuild(data['hc_visits'])
      @set 'syncedAt.hcVisits', data['synced_at']

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

  update: (options = {}) ->
    if options.mode is 'online'
      options.success(reload: true) if options.success
      return

    cache = window.applicationCache
    cache.addEventListener 'updateready', =>
        cache.removeEventListener('updateready', arguments.callee, false)
        if cache.status is cache.UPDATEREADY
          cache.swapCache()
          options.success(reload: true) if options.success
        else
          options.success(reload: false) if options.success
      , false

    cache.addEventListener 'error', (e) =>
        cache.removeEventListener('updateready', arguments.callee, false)
        window.console.error 'Error updating app cache.'
        options.error(e) if options.error
      , false

    cache.update()

  push: (options) ->
    completedHcvs = App.dirtyHcVisits.filter (hcv) => hcv.get('state') == 'complete'
    completedWvs = App.dirtyWarehouseVisits.filter (wv) => wv.get('state') == 'complete'

    syncStatus =
      hcVisits: completedHcvs.length
      warehouseVisits: completedWvs.length
    _.extend(syncStatus, Backbone.Events)

    if syncStatus.hcVisits is 0 and syncStatus.warehouseVisits is 0
      setTimeout (=> syncStatus.trigger('pushed:all')), 1000

    completedHcvs.forEach (hcv) =>
      url = "#{@baseUrl}/hc_visits/#{hcv.get('code')}.json"
      $.ajax
        url: url
        type: 'POST'
        username: options.username
        password: options.password
        contentType: 'application/json; charset=utf-8',
        dataType: 'json'
        data:
          JSON.stringify
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

    completedWvs.forEach (wv) =>
      url = "#{@baseUrl}/warehouse_visits/#{wv.get('code')}.json"
      $.ajax
        url: url
        type: 'POST'
        username: options.username
        password: options.password
        contentType: 'application/json; charset=utf-8',
        dataType: 'json'
        data:
          JSON.stringify
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
