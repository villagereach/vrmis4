var OfflineRouter = Backbone.Router.extend({
  routes: {
    "":                      "root",
    "login":                 "userLoginForm",
    "home":                  "mainUserPage",
    "sync":                  "syncPage",
    "hc_visits/:code":       "hcVisitPage",
    "hc_visits/:code/:tab":  "hcVisitPage",
    "reports/adhoc":         "adhocReportsPage",
		"reports/generic/:month/*scoping":  "genericReportPage",
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
    this.navigate("login", { trigger: true });
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
      model: this.currentUser,
      deliveryZones: this.app.deliveryZones,
      months: this.app.hcVisitMonths,
    });

    var that = this;
    this.mainUserView.on('edit:health_center_visit', function(hcv_code) {
      that.navigate("hc_visits/" + hcv_code, { trigger: true });
    });

    this.currentView = this.mainUserView;
    this.mainUserView.render();
  },

  syncPage: function() {
    this.cleanupCurrentView();

    this.syncView = this.syncView || new Views.Users.Sync({ model: this.app.syncState });

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
        error:   function() { that.newHcVisitView(hcVisit, tabName) },
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
    var idealStockAmounts = healthCenter ? healthCenter.get('ideal_stock_amounts') : [];

    this.hcVisitView = new Views.HcVisits.Edit({
      hcVisit:        hcVisit,
      healthCenter:   healthCenter,
      idealStock:     idealStockAmounts,
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
    // eventually this will create a read-only view, but for now just call edit
    this.editHcVisitView(hcVisit, tabName);
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

	genericReportPage: function(month, scoping) {
		this.cleanupCurrentView();
		var that = this;
    this.genericReportView = new Views.Reports.Generic({
			products: that.app.products,
			healthCenters: that.app.healthCenters,
			hcVisits: that.app.hcVisits,
			visitMonths: that.app.hcVisitMonths,
			scoping: scoping,
			month: month,
			stockCards: that.app.stockCards,
			packages: that.app.packages,
		});

    this.currentView = this.genericReportView;
    this.genericReportView.render();
		
  },

  err404: function(url) {
		this.cleanupCurrentView();
    window.alert("unknown url "+url);
  }
});
