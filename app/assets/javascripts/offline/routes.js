var OfflineRouter = Backbone.Router.extend({
  routes: {
    "":     "root",
    "login":                 "userLoginForm",
    "home":                  "mainUserPage",
    "select_hc/:month/:dzcode":   "selectHcPage",
    "warehouse_visits/:month/:dzcode/ideal": "idealWarehousePage",
    "warehouse_visits/:month/:dzcode": "editWarehousePage",
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
    if (this.app.deliveryZones.length == 0) {
      // not synced with server yet, redirect to sync page
      this.navigate("sync", { trigger: true });
      return;
    }

    this.cleanupCurrentView();

    this.mainUserView = this.mainUserView || new Views.Users.Main({
      deliveryZones: this.app.deliveryZones,
      months: this.app.hcVisitMonths,
    });

    this.currentView = this.mainUserView;
    this.mainUserView.render();
  },

  selectHcPage: function(month, dzCode) {
    this.cleanupCurrentView();
    this.selectHcView =  new Views.Users.SelectHc({
      month: month,
      deliveryZone: this.app.deliveryZones.get(dzCode),
      hcVisits: this.app.hcVisits,
      dirtyHcVisits: this.app.dirtyHcVisits,
    });
    this.currentView = this.selectHcView;
    this.currentView.render();
  },

  idealWarehousePage: function(month, dzCode) {
    this.cleanupCurrentView();
    this.idealWarehouseView = new Views.WarehouseVisits.Ideal({
      month: month,
      deliveryZone: this.app.deliveryZones.get(dzCode),
      products: this.app.products,
      packages: this.app.packages,
    });
    this.currentView = this.idealWarehouseView;
    this.currentView.render();
  },

  editWarehousePage: function(month, dzCode) {
    this.cleanupCurrentView();

    var warehouseVisit = new Models.WarehouseVisit({ code: dzCode+'-'+month });

    this.editWarehouseView = new Views.WarehouseVisits.Edit({
      warehouseVisit: warehouseVisit,
      deliveryZone: this.app.deliveryZones.get(dzCode),
      products: this.app.products,
      packages: this.app.packages,
    });

    this.currentView = this.editWarehouseView;
    this.currentView.render();
  },

  syncPage: function() {
    this.cleanupCurrentView();

    if (this.syncView) {
      delete this.syncView;
      this.syncView = undefined;
    }

    this.syncView = new Views.Users.Sync({ model: this.app.syncState });

    this.currentView = this.syncView;
    this.syncView.render();
  },

  hcVisitPage: function(visitCode, tabName) {
    this.cleanupCurrentView();

    // refreshing existing view w/ new hc visit not supported
    if (this.hcVisitView) {
      delete this.hcVisitView;
      this.hcVisitView = undefined;
    }

    var that = this;
    var hcVisit = this.app.dirtyHcVisits.get(visitCode);
    if (hcVisit) {
      this.editHcVisitView(hcVisit, tabName);
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
    this.cleanupCurrentView();


    this.adhocReportsView = this.adhocReportsView || new Views.Reports.Adhoc({
      months: this.app.hcVisitMonths,
    });

    this.currentView = this.adhocReportsView;
    this.adhocReportsView.render();
  },

  resetDatabase: function() {
    window.location = window.location.pathname.replace(/\/?$/, '/reset');
  },

  summaryReportPage: function(month, scoping) {
    this.cleanupCurrentView();
    var that = this;
    this.summaryReportView = new Views.Reports.Summary({
      products: that.app.products,
      healthCenters: that.app.healthCenters,
      hcVisits: that.app.hcVisits,
      visitMonths: that.app.hcVisitMonths,
      scoping: scoping,
      month: month,
      stockCards: that.app.stockCards,
      packages: that.app.packages,
    });

    this.currentView = this.summaryReportView;
    this.summaryReportView.render();
  },

  err404: function(url) {
    this.cleanupCurrentView();
    window.alert("unknown url "+url);
  }

});
