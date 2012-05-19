class Collections.Districts extends Backbone.Collection
  database: provinceDb
  storeName: 'districts'
  model: Models.District

  constructor: (objs, @snapshot = App.config) ->
    super(objs)

  comparator: (district) ->
    district.get('code')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
