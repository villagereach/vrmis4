class Models.Package extends Backbone.Model
  database: provinceDb
  storeName: 'packages'
  idAttribute: 'code'

  get: (attr) ->
    if _.isFunction(@[attr]) then @[attr]() else super(attr)

  product: ->
    App.products.get(@get('product_code'))

  product_type: ->
    @get('product').get('product_type')
