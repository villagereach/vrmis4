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
function tableField(fName, fVal, required, nr) {
     var fId = 'hc_visit-' + fName.replace(/[.]/g, '-');
     var input = '<input type="number" name="' + fName + '" id="' + fId + '" min="0" value="' + fVal + '" class="input' + (required ? ' validate' : '') + '" />';

     var xvalid = required
       ? '<span id="' + fId + '-x" class="x-invalid" title="This field is required.">&nbsp;</span>'
       : '';

     var nrdiv = nr
       ? '<div class="nr-div"><input type="checkbox" name="nr.' + fName + '" id="' + fId + '-nr" value="NR" class="nr"' + (fVal == 'NR' ? 'checked="checked"' : '') + '/><label for="hc-visit-' + fId + '-nr">NR</label></div>'
       : '';
       
     return input + xvalid + nrdiv;
};