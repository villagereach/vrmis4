Collections.EquipmentTypes = Backbone.Collection.extend({
  database: provinceDb,
  storeName: "equipment_types",
  model: Models.EquipmentType,

  comparator: function(et) {
    return et.get('code');
  },

});
