window.Helpers     ?= {}
window.Models      ?= {}
window.Collections ?= {}
window.Views       ?= { Users: {}, HcVisits: {}, WarehouseVisits: {}, Sync: {}, Reports: {}, Helpers: {} }

class window.OfflineApp
  constructor: (options) ->
    _.extend @, Backbone.Events

    @mode = options.mode
    @baseUrl = window.location.pathname.replace /\/?$/, ''
    @months = options.months
    @users = new Collections.Users([{ accessCode: options.accessCode }])

    @province = options.provinceCode
    @accessCode = options.accessCode

    (new Collections.Snapshots).fetch(success: (c) => @snapshots = c; @config = c.get('live') || new Models.Snapshot)
    (new Collections.HcVisits).fetch(success: (c) => @hcVisits = c)
    (new Collections.DirtyHcVisits).fetch(success: (c) => @dirtyHcVisits = c)
    (new Collections.WarehouseVisits).fetch(success: (c) => @warehouseVisits = c)
    (new Collections.DirtyWarehouseVisits).fetch(success: (c) => @dirtyWarehouseVisits = c)

    (new Models.SyncState(id: 'current', months: @months, baseUrl: @baseUrl)).fetch
      success: (m) => @syncState = m
      error:   (m) => @syncState = m # new db, no sync state yet

    time = setInterval =>
        if @snapshots && @hcVisits && @dirtyHcVisits && @warehouseVisits && @dirtyWarehouseVisits
          clearInterval time
          options.success() if options.success
          @trigger 'ready'
      , 100

  start: ->
    @router = new OfflineRouter @
    Backbone.history.start()
