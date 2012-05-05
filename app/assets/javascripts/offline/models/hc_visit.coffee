class Models.HcVisit extends Backbone.NestedModel
  database: provinceDb,
  storeName: 'hc_visits'
  idAttribute: 'code'

  defaults:
    visited: null,
    visited_at: null,
    vehicle_id: null,
    non_visit_reason: null,
    other_non_visit_reason: null,
    refrigerators: null,

  initialize: ->
    if result = @get('code').match(/^(.+?)-(\d{4}-\d{2})$/)
      @set health_center_code: result[1], month: result[2]

  isEditable: ->
    false

  toJSON: ->
    # include the object's id, needed for backbone-indexeddb
    _.clone(_.extend(@attributes, {id: @id}))


class Models.DirtyHcVisit extends Models.HcVisit
  database: provinceDb
  storeName: 'dirty_hc_visits'
  idAttribute: 'code'

  isEditable: ->
    true
