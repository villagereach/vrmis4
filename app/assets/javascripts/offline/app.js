window.Models = window.Models || {};
window.Collections = window.Collections || {};
window.Views = window.Views || { Users: {}, HcVisits: {}, WarehouseVisits: {}, Reports: {} };

window.OfflineApp = function(options) {
  var options = options || {};

  this.ready = false;

  this.hcVisitMonths = options.hcVisitMonths;

  this.users = new Collections.Users([{ accessCode: options.accessCode }]);

  this.province = options.provinceCode;
  this.products = new Collections.Products;
  this.packages = new Collections.Packages;
  this.stockCards = new Collections.StockCards;
  this.equipmentTypes = new Collections.EquipmentTypes;
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
    var waiting = 9;
    that.syncState.fetch({
      success: function() { waiting-- },
      error:   function() { waiting-- }, // new db, no sync state yet
    });
    that.products.fetch({success: function() { waiting-- }});
    that.packages.fetch({success: function() { waiting-- }});
    that.stockCards.fetch({success: function() { waiting-- }});
    that.equipmentTypes.fetch({success: function() { waiting-- }});
    that.deliveryZones.fetch({success: function() { waiting-- }});
    that.districts.fetch({success: function() { waiting-- }});
    that.healthCenters.fetch({success: function() { waiting-- }});
    that.hcVisits.fetch({success: function() { waiting-- }});
		
    var time = setInterval(function() {
      if (waiting == 0) {
        clearInterval(time);
        if (success) { success.call() }
      }
    }, 100);
  }

  fetchAll(function() {
    that.ready = true;
		window.console.log("ps"+that.packages.length);
    that.trigger('ready');
  });
};

_.extend(window.OfflineApp.prototype, Backbone.Events, {
  start: function() {
    this.router = new OfflineRouter({ app: this });
    Backbone.history.start();
  },
});

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

function deepGet(obj, key) {
  key_array = (typeof(key)=="string") ? key.split(".") : key
  return _.reduce(key_array, function(val,key) {
          val = val || {};
          return val.get ? val.get(key) : val[key]
        }, obj
  );
};

