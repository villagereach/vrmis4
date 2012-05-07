window.Helpers     ?= {}
window.Models      ?= {}
window.Collections ?= {}
window.Views       ?= { Users: {}, HcVisits: {}, WarehouseVisits: {}, Sync: {}, Reports: {} }

class window.OfflineApp
  constructor: (options) ->
    _.extend @, Backbone.Events

    @baseUrl = window.location.pathname.replace /\/?$/, ''
    @months = options.months
    @users = new Collections.Users([{ accessCode: options.accessCode }])

    @province = options.provinceCode
    @accessCode = options.accessCode

    (new Collections.Products).fetch(success: (c) => @products = c)
    (new Collections.Packages).fetch(success: (c) => @packages = c)
    (new Collections.StockCards).fetch(success: (c) => @stockCards = c)
    (new Collections.EquipmentTypes).fetch(success: (c) => @equipmentTypes = c)
    (new Collections.DeliveryZones).fetch(success: (c) => @deliveryZones = c)
    (new Collections.Districts).fetch(success: (c) => @districts = c)
    (new Collections.HealthCenters).fetch(success: (c) => @healthCenters = c)
    (new Collections.Warehouses).fetch(success: (c) => @warehouses = c)
    (new Collections.HcVisits).fetch(success: (c) => @hcVisits = c)
    (new Collections.DirtyHcVisits).fetch(success: (c) => @dirtyHcVisits = c)
    (new Collections.WarehouseVisits).fetch(success: (c) => @warehouseVisits = c)
    (new Collections.DirtyWarehouseVisits).fetch(success: (c) => @dirtyWarehouseVisits = c)

    (new Models.SyncState(id: 'current', months: @months, baseUrl: @baseUrl)).fetch
      success: (m) => @syncState = m
      error:   (m) => @syncState = m # new db, no sync state yet

    time = setInterval =>
        if @products && @packages && @stockCards && @equipmentTypes && @deliveryZones &&
        @districts && @healthCenters && @warehouses && @hcVisits && @dirtyHcVisits && @warehouseVisits && @dirtyWarehouseVisits
          clearInterval time
          options.success() if options.success
          @trigger 'ready'
      , 100

  start: ->
    @router = new OfflineRouter @
    Backbone.history.start()
