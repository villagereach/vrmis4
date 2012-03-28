Models.District = Backbone.Model.extend({
  database: provinceDb,
  storeName: "districts",
  idAttribute: 'code',

  get: function (attr) {
    if (typeof this[attr] == 'function') { return this[attr]() };
    return Backbone.Model.prototype.get.call(this, attr);
  },

  deliveryZone: function() {
    return App.deliveryZones.get(this.get('delivery_zone_code'));
  },

  healthCenters: function() {
    var code = this.get('code');
    var hcs = App.healthCenters.filter(function(hc) {
      return hc.get('district_code') == code;
    });

    return new Collections.HealthCenters(hcs);
  },

});
