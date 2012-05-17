class Collections.Warehouses extends Backbone.Collection
  database: provinceDb
  storeName: 'warehouses'
  model: Models.Warehouse

  constructor: (objs, @snapshot = App.config) ->
    super(objs)

  comparator: (hc) ->
    hc.get('code')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
