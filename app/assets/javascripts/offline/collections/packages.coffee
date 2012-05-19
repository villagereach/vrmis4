class Collections.Packages extends Backbone.Collection
  database: provinceDb
  storeName: 'packages'
  model: Models.Package

  constructor: (objs, @snapshot = App.config) ->
    super(objs)

  comparator: (package) ->
    package.get('position')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
