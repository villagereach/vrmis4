var OfflineRouter = Backbone.Router.extend({
  routes: {
    "":                      "root",
    "login":                 "userLoginForm",
    "home":                  "mainUserPage",
    "hc_visits/:code":       "hcVisitsEdit",
    "hc_visits/:code/:tab":  "hcVisitsEdit",
  },

  tabIdLookup: {
    "visit":         "tab-visit-info",
    "refrigerators": "tab-refrigerators",
    "epi_inventory": "tab-epi-inventory",
    "rdt_inventory": "tab-rdt-inventory",
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
    this.cleanupCurrentView();

    this.mainUserView = this.mainUserView || new Views.Users.Main({
      model: this.currentUser,
      deliveryZones: this.app.deliveryZones,
      months: ['2012-02', '2012-01', '2011-12', '2011-11', '2011-10'],
    });

    var that = this;
    this.mainUserView.on('edit:health_center_visit', function(hcv_code) {
      that.navigate("hc_visits/" + hcv_code, { trigger: true });
    });

    this.currentView = this.mainUserView;
    this.mainUserView.render();
  },

  hcVisitsEdit: function(visitCode, tabName) {
    this.cleanupCurrentView();

    var hcVisit = this.app.hcVisits.get(visitCode);
    if (!hcVisit) {
      hcVisit = new Models.HcVisit({ code: visitCode });
      this.app.hcVisits.add(hcVisit);
    }

    var healthCenter = this.app.healthCenters.get(hcVisit.get('health_center_code'));
    var idealStockAmounts = healthCenter ? healthCenter.get('ideal_stock_amounts') : [];

    // refreshing view w/ current hc visit not yet supported, delete old version
    if (this.editHcVisitView) { delete this.editHcVisitView; }

    this.editHcVisitView = new Views.HcVisits.Container({
      model: hcVisit,
      screens: [
        new Views.HcVisits.EditVisitInfo({ model: hcVisit }),
        new Views.HcVisits.EditRefrigerators({ model: hcVisit }),
        new Views.HcVisits.EditEpiInventory({
          model: hcVisit,
          packages: this.app.packages,
          idealStockAmounts: idealStockAmounts,
        }),
        new Views.HcVisits.EditRdtInventory({
          model: hcVisit,
          packages: this.app.packages,
        }),
      ],
    });

    var tabId = this.tabIdLookup[tabName];
    if (tabId) { this.editHcVisitView.selectTab(tabId); }
    this.editHcVisitView.render();
  },

});
