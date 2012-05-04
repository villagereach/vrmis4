Views.WarehouseVisits.Ideal = Backbone.View.extend({
  template: JST['offline/templates/warehouse_visits/ideal'],

  el: '#offline-container',

  vh: Helpers.View,
  t: Helpers.View.t,

  initialize: function(options) {
    this.month = options.month;
    this.deliveryZone = options.deliveryZone;
    this.districts = this.deliveryZone.get('districts');
    this.productTypes = ['vaccine','syringe','test','safety','fuel'];

    var that = this;
    this.pkgsByType = {};
    _.each(this.productTypes, function(type) {
      var pkgs = options.packages.filter(function(p) { return p.get('product_type') == type });
      that.pkgsByType[type] = new Collections.Packages(pkgs);
    });

    this.pkgsOrdered = _.chain(this.productTypes)
      .map(function(type) { return that.pkgsByType[type].toArray() })
      .flatten()
      .value();

    this.districtTotals = {};
    this.districts.each(function(district) {
      var districtCode = district.get('code');
      var healthCenters = district.get('healthCenters');

      that.districtTotals[districtCode] = {
        population: healthCenters.sum('population')
      };

      options.packages.each(function(pkg) {
        var pkgCode = pkg.get('code');
        that.districtTotals[districtCode][pkgCode] =
          healthCenters.sum('ideal_stock_by_pkg.'+ pkgCode);
      });
    });

    this.deliveryZoneTotal = {
      population: _(this.districtTotals).pluck('population')
        .reduce(function(acc,v) { return acc + v }, 0)
    };
    _(options.packages.pluck('code')).each(function(pkgCode) {
      that.deliveryZoneTotal[pkgCode] = _(that.districtTotals).pluck(pkgCode)
        .reduce(function(acc,v) { return acc + v }, 0)
    });
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template(this));
    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
    return this;
  },

});
