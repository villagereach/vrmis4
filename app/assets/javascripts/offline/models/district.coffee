class Models.District extends Backbone.Model
  database: provinceDb
  storeName: 'districts'
  idAttribute: 'code'

  get: (attr) ->
    if _.isFunction(@[attr]) then @[attr]() else super(attr)

  deliveryZone: ->
    App.deliveryZones.get(@get('delivery_zone_code'))

  healthCenters: ->
    code = @get('code')
    hcs = App.healthCenters.filter (hc) -> hc.get('district_code') is code
    new Collections.HealthCenters(hcs)
