class Collections.HcVisits extends Backbone.Collection
  database: provinceDb
  storeName: 'hc_visits'
  model: Models.HcVisit

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)


class Collections.DirtyHcVisits extends Backbone.Collection
  database: provinceDb
  storeName: 'dirty_hc_visits'
  model: Models.DirtyHcVisit
