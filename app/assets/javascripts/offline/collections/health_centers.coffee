class Collections.HealthCenters extends Backbone.Collection
  database: provinceDb
  storeName: 'health_centers'
  model: Models.HealthCenter

  constructor: (objs, @snapshot = App.config) ->
    super(objs)

  comparator: (hc) ->
    hc.get('code')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)

  sum: (attr) ->
    @reduce (acc, hc) ->
        acc + (hc.get(attr) || 0)
      , 0
