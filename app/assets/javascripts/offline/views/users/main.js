Views.Users.Main = Backbone.View.extend({
  mainTemplate: JST["offline/templates/users/fc_main"],
  selectHcTemplate: JST["offline/templates/users/fc_select_hc"],

  el: "#offline-container",
  screen: "zone-select",
  deliveryZone: null,
  visitMonth: null,
  districts: [],
  healthCenter: null,

  events: {
    "submit": "swallowEvent",
    "click #fc-choose-button":  "selectZone",
    "click #fc-choose-link":    "showZone",
    "click #fc-show-button":    "editZone",
    "click #fc-select-hc-link": "showHcSelection",
    "click #fc-health_center":  "selectHcVisit",
//  "click #fc-reset-search":   "resetSearch",
    "change #fc-health_center-search": "filterHcSelection",
  },

  initialize: function(options) {
    this.months = options.months;
    this.deliveryZones = options.deliveryZones;
    this.deliveryZoneCodes = this.deliveryZones.pluck('code');

    if (options.deliveryZone) { this.deliveryZone = options.deliveryZone; }
    if (options.visitMonth) { this.visitMonth = options.visitMonth; }
  },

  render: function() {
    this.delegateEvents();
    if (this.screen == "hc-select") {
      this.renderSelectHc();
    } else {
      this.renderMain();
    }

    return this;
  },

  renderMain: function() {
    this.$el.html(this.mainTemplate({
      screen: this.screen,
      months: this.months,
      visitMonth: this.visitMonth,
      deliveryZone: (this.deliveryZone ? this.deliveryZone.get('code') : {}),
      deliveryZoneCodes: this.deliveryZoneCodes,
    }));
  },

  renderSelectHc: function() {
    this.$el.html(this.selectHcTemplate({
      screen: this.screen,
      deliveryZone: this.deliveryZone.get('code'),
      districts: this.districtsJSON,
      visitMonth: this.visitMonth,
    }));

    this.origHcOptions = this.$("#fc-health_center").html();
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
  },

  selectZone: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var dzCode = this.$("#fc-delivery_zone").val();
    this.deliveryZone = this.deliveryZones.get(dzCode);
    this.districts = this.deliveryZone.get('districts');
    this.districtsJSON = this.districts.map(function(district) {
      return {
        code: district.get('code'),
        hcCodes: district.get('health_center_codes'),
      };
    });

    this.visitMonth = this.$("#fc-visit_month").val();
    this.screen = "zone-show";

    this.render();
  },

  editZone: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.screen = "zone-select";

    this.render();
  },

  showZone: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.screen = "zone-show";

    this.render();
  },

  showHcSelection: function(e) {
    e.preventDefault();
    e.stopPropagation();

    this.screen = "hc-select";

    this.render();
  },

  selectHcVisit: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var hcCode = this.$("#fc-health_center option:selected").val();
    if (!hcCode) { return; }

    this.trigger("edit:health_center_visit", (hcCode + "-" + this.visitMonth));
  },

  filterHcSelection: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var searchText = $(e.srcElement).val();
    this.$("#fc-health_center").html(this.origHcOptions);

    if (searchText) {
      var searchRegex = new RegExp(searchText, "i");
      this.$("#fc-health_center option").each(function() {
        var match = $(this).text().search(searchRegex);
        if (match < 0) { $(this).remove(); }
      });

      this.$("#fc-health_center optgroup").each(function() {
        if ($(this).children().length == 0) { $(this).remove(); }
      });
    }
  },

//resetSearch: function(e) {
//  e.preventDefault();
//  e.stopPropagation();

//  window.rst = e;
//  this.render();
//},

  swallowEvent: function(e) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  },

});
