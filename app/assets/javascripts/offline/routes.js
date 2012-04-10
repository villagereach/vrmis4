var OfflineRouter = Backbone.Router.extend({
  routes: {
    "":     "root",
    "login":                 "userLoginForm",
    "home":                  "mainUserPage",
    "select_hc/:month/:dzcode":   "selectHcPage",
    "sync":                  "syncPage",
    "hc_visits/:code":       "hcVisitPage",
    "hc_visits/:code/:tab":  "hcVisitPage",
    "reports/adhoc":         "adhocReportsPage",
    "reports/summary/:month/*scoping":  "summaryReportPage",
    "reset":                 "resetDatabase",
    '*url':  "err404",
  },

  initialize: function(options) {
    this.app = options.app;
    this.currentUser = null;
    this.currentView = null;
  },

  cleanupCurrentView: function() {
    if (this.currentView) {
      this.currentView.close();
      this.currentView = null;
    }
  },

  root: function() {
    this.navigate("home", { trigger: true });
  },

  userLoginForm: function() {
    this.cleanupCurrentView();

    this.loginView = this.loginView || new Views.Users.Login({ collection: this.app.users });

    var that = this;
    this.currentView = this.loginView;
    this.loginView.render();
    this.loginView.on('login', function(user) {
      that.currentUser = user;
      that.navigate("home", { trigger: true });
    });
  },

  mainUserPage: function() {
    var that = this;
    ensureLoaded(['deliveryZones'], function() {
      if (that.app.deliveryZones.length == 0) {
        // not synced with server yet, redirect to sync page
        that.navigate("sync", { trigger: true });
        return;
      }

      that.cleanupCurrentView();

      that.mainUserView = that.mainUserView || new Views.Users.Main({
        deliveryZones: that.app.deliveryZones,
        months: that.app.hcVisitMonths,
      });

      that.currentView = that.mainUserView;
      that.mainUserView.render();
    });
  },

  selectHcPage: function(month, dzCode) {
    var that = this;
    ensureLoaded(['deliveryZones', 'hcVisits', 'dirtyHcVisits'], function() {
      that.cleanupCurrentView();
      that.selectHcView =  new Views.Users.SelectHc({
        month: month,
        deliveryZone: that.app.deliveryZones.get(dzCode),
        hcVisits: that.app.hcVisits,
        dirtyHcVisits: that.app.dirtyHcVisits,
      });
      that.currentView = that.selectHcView;
      that.currentView.render();
    });
  },

  syncPage: function() {
    var that = this;
    ensureLoaded(['syncState', 'dirtyHcVisits'], function() {
      that.cleanupCurrentView();

      if (that.syncView) {
        delete that.syncView;
        that.syncView = undefined;
      }

      that.syncView = new Views.Users.Sync({
        model: that.app.syncState,
        dirtyHcVisits: that.app.dirtyHcVisits,
      });

      that.currentView = that.syncView;
      that.syncView.render();
    });
  },

  hcVisitPage: function(visitCode, tabName) {
    var that = this;
    var collectionDeps = [
      'dirtyHcVisits', 'healthCenters', 'products',
      'packages', 'stockCards', 'equipmentTypes',
    ];
    ensureLoaded(collectionDeps, function() {
      that.cleanupCurrentView();

      // refreshing existing view w/ new hc visit not supported
      if (that.hcVisitView) {
        delete that.hcVisitView;
        that.hcVisitView = undefined;
      }

      var hcVisit = that.app.dirtyHcVisits.get(visitCode);
      if (hcVisit) {
        that.editHcVisitView(hcVisit, tabName);
      } else {
        hcVisit = new Models.DirtyHcVisit({ code: visitCode });
        hcVisit.fetch({
          success: function() { that.editHcVisitView(hcVisit, tabName) },
          error:   function() {
            hcVisit = new Models.HcVisit({ code: visitCode });
            hcVisit.fetch({
              success: function() { that.showHcVisitView(hcVisit, tabName) },
              error: function() {
                hcVisit = new Models.DirtyHcVisit({ code: visitCode });
                that.app.dirtyHcVisits.add(hcVisit);
                that.newHcVisitView(hcVisit, tabName);
              },
            });
          },
        });
      }
    });
  },

  newHcVisitView: function(hcVisit, tabName) {
    var healthCenter = this.app.healthCenters.get(hcVisit.get('health_center_code'));
    var districtCode = healthCenter.get('district_code');
    var dzCode = healthCenter.get('delivery_zone_code');

    hcVisit.set('district_code', districtCode);
    hcVisit.set('delivery_zone_code', dzCode);

    this.editHcVisitView(hcVisit, tabName);
  },

  editHcVisitView: function(hcVisit, tabName) {
    var healthCenter = this.app.healthCenters.get(hcVisit.get('health_center_code'));

    this.hcVisitView = new Views.HcVisits.Edit({
      hcVisit:        hcVisit,
      healthCenter:   healthCenter,
      packages:       this.app.packages,
      products:       this.app.products,
      stockCards:     this.app.stockCards,
      equipmentTypes: this.app.equipmentTypes,
    });

    if (tabName) { this.hcVisitView.selectTab(tabName); }
    this.currentView = this.hcVisitView;
    this.currentView.render();
  },

  showHcVisitView: function(hcVisit, tabName) {
    var healthCenter = this.app.healthCenters.get(hcVisit.get('health_center_code'));

    this.hcVisitView = new Views.HcVisits.Show({
      hcVisit:        hcVisit,
      healthCenter:   healthCenter,
      packages:       this.app.packages,
      products:       this.app.products,
      stockCards:     this.app.stockCards,
      equipmentTypes: this.app.equipmentTypes,
    });

    if (tabName) { this.hcVisitView.selectTab(tabName); }
    this.currentView = this.hcVisitView;
    this.currentView.render();
  },

  adhocReportsPage: function() {
    var that = this;
    ensureLoaded(['deliveryZones', 'districts'], function() {
      that.cleanupCurrentView();

      that.adhocReportsView = that.adhocReportsView || new Views.Reports.Adhoc({
        months: that.app.hcVisitMonths,
        deliveryZones: that.app.deliveryZones,
        districts: that.app.districts,
      });

      that.currentView = that.adhocReportsView;
      that.adhocReportsView.render();
    });
  },

  resetDatabase: function() {
    window.location = window.location.pathname.replace(/\/?$/, '/reset');
  },

  summaryReportPage: function(month, scoping) {
    var that = this;
    var collectionDeps = [
      'products', 'packages', 'stockCards', 'deliveryZones', 'healthCenters', 'hcVisits',
    ];
    ensureLoaded(collectionDeps, function() {
      that.cleanupCurrentView();
      that.summaryReportView = new Views.Reports.Summary({
        province: that.app.province,
        deliveryZones: that.app.deliveryZones,
        healthCenters: that.app.healthCenters,
        hcVisits: that.app.hcVisits,
        visitMonths: that.app.hcVisitMonths,
        scoping: scoping,
        month: month,
        products: that.app.products,
        packages: that.app.packages,
        stockCards: that.app.stockCards,
      });

      that.currentView = that.summaryReportView;
      that.summaryReportView.render();
    });
  },

  err404: function(url) {
    this.cleanupCurrentView();
    window.alert("unknown url "+url);
  }

});
