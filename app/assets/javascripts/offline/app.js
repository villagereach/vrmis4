window.Models = window.Models || {};
window.Collections = window.Collections || {};
window.Views = window.Views || { Users: {}, HcVisits: {}, WarehouseVisits: {} };

window.OfflineApp = function(options) {
  var options = options || {};

  this.ready = false;

  this.hcVisitMonths = options.hcVisitMonths;

  this.users = new Collections.Users([{ accessCode: options.accessCode }]);

  this.province = options.provinceCode;
  this.products = new Collections.Products;
  this.packages = new Collections.Packages;
  this.deliveryZones = new Collections.DeliveryZones;
  this.districts = new Collections.Districts;
  this.healthCenters = new Collections.HealthCenters;
  this.hcVisits = new Collections.HcVisits;

  this.syncState = new Models.SyncState({
    id:            'current',
    hcVisitMonths: this.hcVisitMonths,
  });

  var that = this;
  function fetchAll(success) {
    var waiting = 6;
    that.syncState.fetch({
      success: function() { waiting-- },
      error:   function() { waiting-- }, // new db, no sync state yet
    });
    that.products.fetch({success: function() { waiting-- }});
    that.packages.fetch({success: function() { waiting-- }});
    that.deliveryZones.fetch({success: function() { waiting-- }});
    that.districts.fetch({success: function() { waiting-- }});
    that.healthCenters.fetch({success: function() { waiting-- }});

    var time = setInterval(function() {
      if (waiting == 0) {
        clearInterval(time);
        if (success) { success.call() }
      }
    }, 100);
  }

  fetchAll(function() {
    that.ready = true;
    that.trigger('ready');
  });
};

_.extend(window.OfflineApp.prototype, Backbone.Events, {
  start: function() {
    this.router = new OfflineRouter({ app: this });
    Backbone.history.start();
  },
});
