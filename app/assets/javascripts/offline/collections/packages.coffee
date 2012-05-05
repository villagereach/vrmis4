class Collections.Packages extends Backbone.Collection
  database: provinceDb
  storeName: 'packages'
  model: Models.Package

  comparator: (package) ->
    package.get('position')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
