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
      _.each(data['products'], function(p) {
        var orig = App.products.get(p.code);
        if (orig) { orig.destroy(); }
        App.products.create(p);
      });

      _.each(data['packages'], function(p) {
        var orig = App.packages.get(p.code);
        if (orig) { orig.destroy(); }
        App.packages.create(p);
      });

      _.each(data['stock_cards'], function(sc) {
        var orig = App.stockCards.get(sc.code);
        if (orig) { orig.destroy(); }
        App.stockCards.create(sc);
      });

      _.each(data['equipment_types'], function(et) {
        var orig = App.equipmentTypes.get(et.code);
        if (orig) { orig.destroy(); }
        App.equipmentTypes.create(et);
      });

      that.set('syncedAt', _.extend(that.get('syncedAt'), { products: data['synced_at'] }));
      syncStatus.products = 'synced';
      syncStatus.trigger('pulled:products');
      if (_.all(syncStatus.models, function(k) { return syncStatus[k] == 'synced' })) {
        syncStatus.synced = true;
        syncStatus.trigger('pulled:all');
      }
    });

    // delivery zones and districts
    var dzParams = { since: this.get('syncedAt').deliveryZones };
    $.getJSON(this.baseUrl + '/delivery_zones.json', dzParams, function(data) {
      _.each(data['delivery_zones'], function(dz) {
        var orig = App.deliveryZones.get(dz.code);
        if (orig) { orig.destroy(); }
        App.deliveryZones.create(dz);
      });

      _.each(data['districts'], function(d) {
        var orig = App.districts.get(d.code);
        if (orig) { orig.destroy(); }
        App.districts.create(d);
      });

      that.set('syncedAt', _.extend(that.get('syncedAt'), { deliveryZones: data['synced_at'] }));
      syncStatus.deliveryZones = 'synced';
      syncStatus.trigger('pulled:deliveryZones');
      if (_.all(syncStatus.models, function(k) { return syncStatus[k] == 'synced' })) {
        syncStatus.synced = true;
        syncStatus.trigger('pulled:all');
      }
    });

    // health centers
    var hcParams = { since: this.get('syncedAt').healthCenters };
    $.getJSON(this.baseUrl + '/health_centers.json', hcParams, function(data) {
      var hcs = new Collections.HealthCenters(data['health_centers']);

      _.each(data['health_centers'], function(hc) {
        var orig = App.healthCenters.get(hc.code);
        if (orig) { orig.destroy(); }
        App.healthCenters.create(hc);
      });

      that.set('syncedAt', _.extend(that.get('syncedAt'), { healthCenters: data['synced_at'] }));
      syncStatus.healthCenters = 'synced';
      syncStatus.trigger('pulled:healthCenters');
      if (_.all(syncStatus.models, function(k) { return syncStatus[k] == 'synced' })) {
        syncStatus.synced = true;
        syncStatus.trigger('pulled:all');
      }
    });

    // health center visits
    var hcvParams = { since: this.get('syncedAt').hcVisits, months: monthsToSync.join(',') };
    $.getJSON(this.baseUrl + '/hc_visits.json', hcvParams, function(data) {
      var hcvs = new Collections.HcVisits(data['hc_visits']);

      _.each(data['hc_visits'], function(hcv) {
        var orig = App.hcVisits.get(hcv.code);
        if (orig) { orig.destroy(); }
        App.hcVisits.create(hcv);
      });

      that.set('syncedAt', _.extend(that.get('syncedAt'), { hcVisits: data['synced_at'] }));
      that.set('hcVisitMonths', monthsToSync);
      syncStatus.hcVisits = 'synced';
      syncStatus.trigger('pulled:hcVisits');
      if (_.all(syncStatus.models, function(k) { return syncStatus[k] == 'synced' })) {
        syncStatus.synced = true;
        syncStatus.trigger('pulled:all');
      }
    });

    return syncStatus;
  },

  push: function(options) {
    options = options || {};
    var that = this;

    var syncStatus = {
      hcVisits: App.dirtyHcVisits.length,
    };

    _.extend(syncStatus, Backbone.Events);

    _.each(App.dirtyHcVisits.filter(function(hcv) { return hcv.get('state') == 'complete' }), function(hcv) {
      var url = this.baseUrl + '/hc_visits/' + hcv.get('code') + '.json';
      $.post(url, { code: hcv.get('code'), data: hcv.toJSON() }, function(data) {
        if (data && data.result == 'success') {
          window.console.log('pushed hcv for ' + hcv.get('code'));
          App.dirtyHcVisits.remove(hcv);
          hcv.destroy();
          syncStatus.hcVisits -= 1;
          syncStatus.trigger('pushed:hcVisit');
          if (syncStatus.hcVisits === 0) {
            syncStatus.trigger('pushed:hcVisits');
          }
        } else {
          window.console.error('hcv push error: ' + JSON.stringify(data));
        }
      });
    });

    return syncStatus;
  },

});
