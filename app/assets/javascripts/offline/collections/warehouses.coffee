class Collections.Warehouses extends Backbone.Collection
  database: provinceDb
  storeName: 'warehouses'
  model: Models.Warehouse

  comparator: (hc) ->
    hc.get('code')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
