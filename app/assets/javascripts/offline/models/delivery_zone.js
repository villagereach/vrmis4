Models.DeliveryZone = Backbone.Model.extend({
  database: provinceDb,
  storeName: "delivery_zones",
  idAttribute: 'code',

  get: function (attr) {
    if (typeof this[attr] == 'function') { return this[attr]() };
    return Backbone.Model.prototype.get.call(this, attr);
  },

  districts: function() {
    var code = this.get('code');
    var districts = App.districts.filter(function(d) {
      return d.get('delivery_zone_code') == code;
    });

    return new Collections.Districts(districts);
  },

});
