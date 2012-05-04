class Collections.Districts extends Backbone.Collection
  database: provinceDb
  storeName: 'districts'
  model: Models.District

  comparator: (district) ->
    district.get('code')
