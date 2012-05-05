class Collections.EquipmentTypes extends Backbone.Collection
  database: provinceDb
  storeName: 'equipment_types'
  model: Models.EquipmentType

  comparator: (et) ->
    et.get('position')

  rebuild: (objs) ->
    for obj in objs
      @get(obj.code)?.destroy()
      @create(obj)
