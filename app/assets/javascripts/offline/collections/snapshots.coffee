class Collections.Snapshots extends Backbone.Collection
  database: provinceDb
  storeName: 'snapshots'
  model: Models.Snapshot

  rebuild: (objs) ->
    for obj in objs
      obj.month ?= 'live'
      @get(obj.month)?.destroy()
      model = @create(obj)
      model.clearCache()
