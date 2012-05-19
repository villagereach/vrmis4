class Models.DeliveryZone extends Backbone.Model
  database: provinceDb
  storeName: 'delivery_zones'
  idAttribute: 'code'

  get: (attr) ->
    if _.isFunction(@[attr]) then @[attr]() else super(attr)

  districts: ->
    code = @get('code')
    districts = @collection.snapshot.districts().filter (d) ->
      d.get('delivery_zone_code') is code
    new Collections.Districts(districts)

  healthCenters: ->
    code = @get('code')
    hcs = @collection.snapshot.healthCenters().filter (hc) ->
      hc.get('delivery_zone_code') is code
    new Collections.HealthCenters(hcs)
