class Models.District extends Backbone.Model
  database: provinceDb
  storeName: 'districts'
  idAttribute: 'code'

  get: (attr) ->
    if _.isFunction(@[attr]) then @[attr]() else super(attr)

  deliveryZone: ->
    @collection.snapshot.deliveryZones().get(@get('delivery_zone_code'))

  healthCenters: ->
    code = @get('code')
    hcs = @collection.snapshot.healthCenters().filter (hc) ->
      hc.get('district_code') is code
    new Collections.HealthCenters(hcs)
