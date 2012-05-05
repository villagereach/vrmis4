class Models.WarehouseVisit extends Backbone.NestedModel
  database: provinceDb
  storeName: 'warehouse_visits'
  idAttribute: 'code'

  initialize: ->
    if result = @get('code').match(/^(.+?)-(\d{4}-\d{2})$/)
      @set delivery_zone_code: result[1], month: result[2]

  isEditable: ->
    false

  toJSON: ->
    # include the object's id, needed for backbone-indexeddb
    _.clone(_.extend(@attributes, {id: @id}))


class Models.DirtyWarehouseVisit extends Models.WarehouseVisit
  database: provinceDb
  storeName: 'dirty_warehouse_visits'
  idAttribute: 'code'

  isEditable: ->
    true
