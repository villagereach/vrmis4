class Models.HealthCenter extends Backbone.NestedModel
  database: provinceDb
  storeName: 'health_centers'
  idAttribute: 'code'

  get: (attr, opts) ->
    keyParts = Backbone.NestedModel.attrPath(attr)
    if _.isFunction(@[keyParts[0]])
      # first part of keypath is a method local to object, apply method first
      val = @[keyParts.shift()]()

      if !keyParts.length
        # no part of keypath remains, this is our value
        return result
      else if _.isFunction(val.get)
        # local method returned an object w/ a get() method, use it
        return val.get(keyParts.join('.'), opts)
      else
        # assume plain objects for the rest of the keypath
        return keyParts.reduce ((v,k) -> (v||{})[k]), val

    else
      # no local function matching key, call prototype/super method
      return Backbone.NestedModel::get.call(@, attr, opts)

  ideal_stock_by_pkg:
    _.memoize ->
      isas = @get('ideal_stock_amounts', { silent: true })
      App.packages.reduce (h, pkg) ->
          value = (isas[pkg.get('product_code')] || 0) / pkg.get('quantity')
          h[pkg.get('code')] = Math.round(value)
          h
        , {}
    , -> @get('id') # memoize by health center id (not code)
