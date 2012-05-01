window.Helpers.Reports =
  deepGet: (obj, key) ->
    key_array = if _.isString(key) then key.split('.') else key
    _.reduce key_array, (val, key) ->
        val ?= {}
        if val.get then val.get(key) else val[key]
      , obj
