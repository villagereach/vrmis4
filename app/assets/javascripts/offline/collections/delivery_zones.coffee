class Collections.DeliveryZones extends Backbone.Collection
  database: provinceDb
  storeName: 'delivery_zones'
  model: Models.DeliveryZone

  constructor: (objs, @snapshot = App.config) ->
    super(objs)

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
