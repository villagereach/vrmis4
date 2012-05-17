class Models.Snapshot extends Backbone.Model
  database: provinceDb
  storeName: 'snapshots'
  idAttribute: 'month'

  cache: {}

  clearCache: ->
    @cache = {}
    @

  deliveryZones: ->
    @cache['deliveryZones'] ?= new Collections.DeliveryZones(@get('delivery_zones'), @)

  districts: ->
    @cache['districts'] ?= new Collections.Districts(@get('districts'), @)

  healthCenters: ->
    @cache['healthCenters'] ?= new Collections.HealthCenters(@get('health_centers'), @)

  warehouses: ->
    @cache['warehouses'] ?= new Collections.Warehouses(@get('warehouses'), @)

  products: ->
    @cache['products'] ?= new Collections.Products(@get('products'), @)

  packages: ->
    @cache['packages'] ?= new Collections.Packages(@get('packages'), @)

  equipmentTypes: ->
    @cache['equipmentTypes'] ?= new Collections.EquipmentTypes(@get('equipment_types'), @)

  stockCards: ->
    @cache['stockCards'] ?= new Collections.StockCards(@get('stock_cards'), @)
