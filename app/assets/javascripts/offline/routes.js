var OfflineRouter = Backbone.Router.extend({
  routes: {
    "":                      "root",
    "login":                 "userLoginForm",
    "home":                  "mainUserPage",
    "sync":                  "syncPage",
    "hc_visits/:code":       "hcVisitsEdit",
    "hc_visits/:code/:tab":  "hcVisitsEdit",
    "reports/adhoc":         "adhocReportsPage",
		"reports/generic/*scoping":  "genericReportPage",
    "reset":                 "resetDatabase",
  },

  tabIdLookup: {
    "visit":            "tab-visit-info",
    "refrigerators":    "tab-refrigerators",
    "epi_inventory":    "tab-epi-inventory",
    "rdt_inventory":    "tab-rdt-inventory",
    "equipment_status": "tab-equipment-status",
    "stock_cards":      "tab-stock-cards",
    "rdt_stock":        "tab-rdt-stock",
    "epi_stock":        "tab-epi-stock",
    "full_vac_tally":   "tab-full-vac-tally",
    "child_vac_tally":  "tab-child-vac-tally",
    "adult_vac_tally":  "tab-adult-vac-tally",
    "observations":     "tab-observations",
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

  hcVisitsEdit: function(visitCode, tabName) {
    this.cleanupCurrentView();

    var that = this;
    var hcVisit = new Models.HcVisit({ code: visitCode });

    function buildHcVisitsView() {
      var healthCenter = that.app.healthCenters.get(hcVisit.get('health_center_code'));
      var idealStockAmounts = healthCenter ? healthCenter.get('ideal_stock_amounts') : [];

      // refreshing view w/ current hc visit not yet supported, delete old version
      if (that.editHcVisitView) { delete that.editHcVisitView; }

      that.editHcVisitView = new Views.HcVisits.Container({
        model: hcVisit,
        screens: [
          new Views.HcVisits.EditVisitInfo({ model: hcVisit }),
          new Views.HcVisits.EditRefrigerators({ model: hcVisit }),
          new Views.HcVisits.EditEpiInventory({
            model: hcVisit,
            packages: that.app.packages,
            idealStockAmounts: idealStockAmounts,
          }),
          new Views.HcVisits.EditRdtInventory({
            model: hcVisit,
            packages: that.app.packages,
          }),
          new Views.HcVisits.EditEquipmentStatus({ model: hcVisit }),
          new Views.HcVisits.EditStockCards({
            model: hcVisit,
            packages: that.app.packages,
          }),
          new Views.HcVisits.EditRdtStock({
            model: hcVisit,
            packages: that.app.packages,
          }),
          new Views.HcVisits.EditEpiStock({
            model: hcVisit,
            products: that.app.products,
          }),
          new Views.HcVisits.EditFullVacTally({ model: hcVisit }),
          new Views.HcVisits.EditChildVacTally({
            model: hcVisit,
            healthCenter: healthCenter,
            packages: that.app.packages,
          }),
          new Views.HcVisits.EditAdultVacTally({
            model: hcVisit,
            healthCenter: healthCenter,
            packages: that.app.packages,
          }),
          new Views.HcVisits.EditObservations({ model: hcVisit }),
        ],
      });

      var tabId = that.tabIdLookup[tabName];
      if (tabId) { that.editHcVisitView.selectTab(tabId); }
      that.editHcVisitView.render();
    }

    hcVisit.fetch({ success: buildHcVisitsView, error: buildHcVisitsView });
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

	genericReportPage: function(scoping) {
		this.cleanupCurrentView();
		
		var that = this;
    this.genericReportView = this.genericReportView || new Views.Reports.Generic({
			products: that.app.products,
			healthCenters: that.app.healthCenters,
			hcVisits: that.app.hcVisits,
			visitMonths: that.app.hcVisitMonths,
			scoping: scoping,
			stockCards: that.app.stockCards,
		});

    this.currentView = this.genericReportView;
    this.genericReportView.render();
		
  },

});
