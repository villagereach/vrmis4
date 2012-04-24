window.Models = window.Models || {};
window.Collections = window.Collections || {};
window.Views = window.Views || { Users: {}, HcVisits: {}, WarehouseVisits: {}, Reports: {} };
window.Helpers = window.Helpers || {};

window.OfflineApp = function(options) {
  var options = options || {};

  this.ready = false;
  this.hcVisitMonths = options.hcVisitMonths;
  this.users = new Collections.Users([{ accessCode: options.accessCode }]);
  this.province = options.provinceCode;

  var that = this;
  (new Collections.Products).fetch({ success: function(c) { that.products = c } });
  (new Collections.Packages).fetch({ success: function(c) { that.packages = c } });
  (new Collections.StockCards).fetch({ success: function(c) { that.stockCards = c } });
  (new Collections.EquipmentTypes).fetch({ success: function(c) { that.equipmentTypes = c } });
  (new Collections.DeliveryZones).fetch({ success: function(c) { that.deliveryZones = c } });
  (new Collections.Districts).fetch({ success: function(c) { that.districts = c } });
  (new Collections.HealthCenters).fetch({ success: function(c) { that.healthCenters = c } });
  (new Collections.HcVisits).fetch({ success: function(c) { that.hcVisits = c } });
  (new Collections.DirtyHcVisits).fetch({ success: function(c) { that.dirtyHcVisits = c } });

  var syncState = new Models.SyncState({ id: 'current', hcVisitMonths: this.hcVisitMonths });
  syncState.fetch({
    success: function(c) { that.syncState = c },
    error:   function(c) { that.syncState = c },
  });
};

_.extend(window.OfflineApp.prototype, Backbone.Events, {
  start: function() {
    this.router = new OfflineRouter({ app: this });
    Backbone.history.start();
  },

  //App.ready = true;
  //App.trigger('ready');
});

function ensureLoaded(collections, callback) {
  var remaining = _.reject(collections, function(c) { return App[c] });
  if (_.isEmpty(remaining)) { callback.call(); return; }

  var time = setInterval(function() {
    remaining = _.reject(remaining, function(c) { return App[c] });
    if (_.isEmpty(remaining)) {
      clearInterval(time);
      callback.call();
    }
  }, 50);
}

function deepGet(obj, key) {
  key_array = (typeof(key)=="string") ? key.split(".") : key
  return _.reduce(key_array, function(val,key) {
          val = val || {};
          return val.get ? val.get(key) : val[key]
        }, obj
  );
};

function goTo(hash, e) {
  if (e) {
    e.preventDefault();
    e.stopPropagation();
  }
  App.router.navigate(hash, true);
};
