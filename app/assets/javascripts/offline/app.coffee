window.Helpers     ?= {}
window.Models      ?= {}
window.Collections ?= {}
window.Views       ?= { Users: {}, HcVisits: {}, WarehouseVisits: {}, Reports: {} }

class window.OfflineApp
  constructor: (options) ->
    _.extend @, Backbone.Events

    @hcVisitMonths = options.hcVisitMonths
    @users = new Collections.Users([{ accessCode: options.accessCode }])

    @province = options.provinceCode

    (new Collections.Products).fetch(success: (c) => @products = c)
    (new Collections.Packages).fetch(success: (c) => @packages = c)
    (new Collections.StockCards).fetch(success: (c) => @stockCards = c)
    (new Collections.EquipmentTypes).fetch(success: (c) => @equipmentTypes = c)
    (new Collections.DeliveryZones).fetch(success: (c) => @deliveryZones = c)
    (new Collections.Districts).fetch(success: (c) => @districts = c)
    (new Collections.HealthCenters).fetch(success: (c) => @healthCenters = c)
    (new Collections.HcVisits).fetch(success: (c) => @hcVisits = c)
    (new Collections.DirtyHcVisits).fetch(success: (c) => @dirtyHcVisits = c)

    (new Models.SyncState(id: 'current', hcVisitMonths: @hcVisitMonths)).fetch
      success: (m) => @syncState = m
      error:   (m) => @syncState = m # new db, no sync state yet

    time = setInterval =>
        if @products && @packages && @stockCards && @equipmentTypes && @deliveryZones &&
        @districts && @healthCenters && @hcVisits && @dirtyHcVisits
          clearInterval time
          options.success() if options.success
          @trigger 'ready'
      , 100

  start: ->
    @router = new OfflineRouter @
    Backbone.history.start()
