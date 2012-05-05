class Collections.WarehouseVisits extends Backbone.Collection
  database: provinceDb
  storeName: 'warehouse_visits'
  model: Models.WarehouseVisit

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)


class Collections.DirtyWarehouseVisits extends Backbone.Collection
  database: provinceDb
  storeName: 'dirty_warehouse_visits'
  model: Models.DirtyWarehouseVisit
