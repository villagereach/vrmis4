window.Models = window.Models || {};
window.Collections = window.Collections || {};
window.Views = window.Views || { Users: {}, HcVisits: {}, WarehouseVisits: {} };

window.OfflineApp = function(options) {
  var options = options || {};

  this.products = new Collections.Products(options.products);
  this.packages = new Collections.Packages(_.flatten(
    this.products.map(function(p) { return p.get('packages').toArray() })
  ))

  this.users = new Collections.Users([{ accessCode: options.accessCode }]);
  this.deliveryZones = new Collections.DeliveryZones(options.deliveryZones);
  this.healthCenters = new Collections.HealthCenters(options.healthCenters);
  this.hcVisits = new Collections.HcVisits();

  this.hcVisits.fetch(); // loads from local storage

  this.router = new OfflineRouter({ app: this });
  Backbone.history.start();
};
