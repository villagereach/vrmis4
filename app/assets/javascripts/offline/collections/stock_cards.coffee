class Collections.StockCards extends Backbone.Collection
  database: provinceDb
  storeName: 'stock_cards'
  model: Models.StockCard

  constructor: (objs, @snapshot = App.config) ->
    super(objs)

  comparator: (sc) ->
    sc.get('position')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
