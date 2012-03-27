Models.SyncState = Backbone.Model.extend({
  database: provinceDb,
  storeName: "sync_states",

  defaults: {
    syncedAt: {},
    hcVisitMonths: [],
  },

  initialize: function(options) {
    options = options || {};
    this.baseUrl = options.baseUrl || window.location.pathname.replace(/\/?$/, '');
    this.reqMonths = options.hcVisitMonths || [];
  },

  pull: function(options) {
    options = options || {};
    var that = this;

    var monthsToSync = _.union(this.get('hcVisitMonths'), this.reqMonths, (options.months||[])).sort();

    var syncStatus = {
      models:        ['products', 'deliveryZones', 'healthCenters', 'hcVisits'],
      products:      'pending',
      deliveryZones: 'pending',
      healthCenters: 'pending',
      hcVisits:      'pending',
      synced:        false,
    };
    _.extend(syncStatus, Backbone.Events);
    syncStatus.on('pulled:all', function() { that.save() });

    // products and packages
    var prodParams = { since: this.get('syncedAt').products };
    $.getJSON(this.baseUrl + '/products.json', prodParams, function(data) {
      var products = new Collections.Products(data['products']);
      var packages = new Collections.Packages(_.flatten(
        products.map(function(p) { return p.get('packages').toArray() })
      ));
      var stockCards = new Collections.StockCards(data['stock_cards']);
      var equipmentTypes = new Collections.EquipmentTypes(data['equipment_types']);

      products.each(function(p) { p.save() });
      packages.each(function(p) { p.save() });
      stockCards.each(function(sc) { sc.save() });
      equipmentTypes.each(function(et) { et.save() });

      App.products.fetch({success: function() {
        App.packages.fetch({success: function() {
          App.stockCards.fetch({success: function() {
            App.equipmentTypes.fetch({success: function() {
              that.set('syncedAt', _.extend(that.get('syncedAt'), { products: data['synced_at'] }));
              syncStatus.products = 'synced';
              syncStatus.trigger('pulled:products');
              if (_.all(syncStatus.models, function(k) { return syncStatus[k] == 'synced' })) {
                syncStatus.synced = true;
                syncStatus.trigger('pulled:all');
              }
            }});
          }});
        }});
      }});
    });

    // delivery zones and districts
    var dzParams = { since: this.get('syncedAt').deliveryZones };
    $.getJSON(this.baseUrl + '/delivery_zones.json', dzParams, function(data) {
      var dzs = new Collections.DeliveryZones(data['delivery_zones']);
      var districts = new Collections.Districts(_.flatten(
        dzs.map(function(dz) { return dz.get('districts').toArray() })
      ));

      dzs.each(function(dz) { dz.save() });
      districts.each(function(d) { d.save() });

      App.deliveryZones.fetch({success: function() {
        App.districts.fetch({success: function() {
          that.set('syncedAt', _.extend(that.get('syncedAt'), { deliveryZones: data['synced_at'] }));
          syncStatus.deliveryZones = 'synced';
          syncStatus.trigger('pulled:deliveryZones');
          if (_.all(syncStatus.models, function(k) { return syncStatus[k] == 'synced' })) {
            syncStatus.synced = true;
            syncStatus.trigger('pulled:all');
          }
        }});
      }});
    });

    // health centers
    var hcParams = { since: this.get('syncedAt').healthCenters };
    $.getJSON(this.baseUrl + '/health_centers.json', hcParams, function(data) {
      var hcs = new Collections.HealthCenters(data['health_centers']);

      hcs.each(function(hc) { hc.save() });

      App.healthCenters.fetch({success: function() {
        that.set('syncedAt', _.extend(that.get('syncedAt'), { healthCenters: data['synced_at'] }));
        syncStatus.healthCenters = 'synced';
        syncStatus.trigger('pulled:healthCenters');
        if (_.all(syncStatus.models, function(k) { return syncStatus[k] == 'synced' })) {
          syncStatus.synced = true;
          syncStatus.trigger('pulled:all');
        }
      }});
    });

    // health center visits
    var hcvParams = { since: this.get('syncedAt').hcVisits, months: monthsToSync.join(',') };
    $.getJSON(this.baseUrl + '/hc_visits.json', hcvParams, function(data) {
      var hcvs = new Collections.HcVisits(data['hc_visits']);

      hcvs.each(function(hcv) { hcv.save() });

      App.hcVisits.fetch({success: function() {
        that.set('syncedAt', _.extend(that.get('syncedAt'), { hcVisits: data['synced_at'] }));
        that.set('hcVisitMonths', monthsToSync);
        syncStatus.hcVisits = 'synced';
        syncStatus.trigger('pulled:hcVisits');
        if (_.all(syncStatus.models, function(k) { return syncStatus[k] == 'synced' })) {
          syncStatus.synced = true;
          syncStatus.trigger('pulled:all');
        }
      }});
    });

    return syncStatus;
  },

});
