class Collections.Districts extends Backbone.Collection
  database: provinceDb
  storeName: 'districts'
  model: Models.District

  comparator: (district) ->
    district.get('code')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
