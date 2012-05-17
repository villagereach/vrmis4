class Collections.EquipmentTypes extends Backbone.Collection
  database: provinceDb
  storeName: 'equipment_types'
  model: Models.EquipmentType

  constructor: (objs, @snapshot = App.config) ->
    super(objs)

  comparator: (et) ->
    et.get('position')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
