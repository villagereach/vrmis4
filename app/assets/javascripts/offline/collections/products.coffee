class Collections.Products extends Backbone.Collection
  database: provinceDb
  storeName: 'products'
  model: Models.Product

  comparator: (product) ->
    product.get('position')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
