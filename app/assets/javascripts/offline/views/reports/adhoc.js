Views.Reports.Adhoc = Backbone.View.extend({
  template: JST["offline/templates/reports/adhoc"],

  el: "#offline-container",

  events: {
    "click  .definition-name a":           "calcDefinition",
    "click  #reports-adhoc-calculate":     "calculate",
    "click  #reports-adhoc-show":          "show",
    "change #reports-adhoc-month":         "selectMonth",
    "change #reports-adhoc-delivery_zone": "selectDeliveryZone",
    "change #reports-adhoc-district":      "selectDistrict",
    "change #reports-adhoc-definitions":   "changeDefinitions",
  },

  defaultDefinitions: [
    // see rebuildCalcGraph method for dynamic definitions (hcVisits, etc)
    { name: "products",
      method: "collection",
      collection: "Products",
    },
    { name: "packages",
      method: "collection",
      collection: "Packages",
    },
    { name: "stockCards",
      method: "collection",
      collection: "StockCards",
    },
    { name: "equipmentTypes",
      method: "collection",
      collection: "EquipmentTypes",
    },
  ],

  initialize: function(options) {
    this.months = options.months;
    this.deliveryZones = options.deliveryZones;
    this.districts = options.districts;
    this.allDistricts = options.districts;
    this.definitions = [];
    this.customDefinitions = [];

    this.month = this.months[0];

    this.rebuildCalcGraph();
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template({
      months: this.months,
      month: this.month,
      deliveryZones: this.deliveryZones,
      dzCode: this.dzCode,
      districts: this.districts,
      districtCode: this.districtCode,
      definitions: this.definitions,
      definitionsJSON: this.definitionsJSON,
      definitionErrors: this.definitionErrors,
    }));
    this.$("#reports-adhoc-definitions").focus();

    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
  },

  rebuildCalcGraph: function() {
    var conditions = {};
    if (this.districtCode) { conditions.district_code = this.districtCode; }
    if (this.dzCode) { conditions.delivery_zone_code = this.dzCode; }

    var hcvConditions = _.clone(conditions);
    hcvConditions.month = this.month;
    var hcvVisitedConditions = _.clone(hcvConditions);
    hcvVisitedConditions.visited = true;

    this.definitions = _.union(this.defaultDefinitions, [
      { name:       'hcVisits',
        method:     'collection',
        collection: 'HcVisits',
        index:      'month',
        conditions: hcvConditions
      },
      { name:    'hcVisitsCount',
        method:  'count',
        values:  {"ref": "hcVisits"}
      },
      { name:   'hcVisitsVisited',
        method:  'collection',
        collection: 'HcVisits',
        index: 'month',
        conditions:  hcvVisitedConditions
      },
      { name:  'hcVisitsVisitedCount',
        method: 'count',
        values:  {"ref": "hcVisitsVisited"}
      },
      { name: 'VisitedValues',
        method: 'pluck',
        keypath: 'visited',
        values: {"ref": "hcVisits"},
      },
      { name: 'hcVisitsVisitedCount2',
        method: 'count',
        count_if_equal_to: true,
        values:  {"ref":  "VisitedValues"}
      },
      { name: 'hcVisitsVisitedCount3',
        method: 'count',
        count_if_not_equal_to: false,
        values:  {"ref":  "VisitedValues"}
      },

      { name: 'hcVisitsNOTVisitedCount',
        method: 'count',
        count_if_equal_to: false,
        values:  {"ref":  "VisitedValues"}
      },

      { name:       'healthCenters',
        method:     'collection',
        collection: 'HealthCenters',
        conditions: conditions
      },
      { name:  'healthCentersCount',
        method: 'count',
        values: {"ref": "healthCenters"}
      }
    ], this.customDefinitions),

    this.calcGraph = new Models.CalcGraph({
      methods: this.calcMethods,
      definitions: this.definitions,
      afterCalculate: function(values) {
        if (_.isArray(values)) {
          return values.map(function(value) { return value == 'NR' ? null : value });
        } else {
          return values == 'NR' ? null : values;
        }
      },
    });
  },

  selectMonth: function(e) {
    e.preventDefault();

    this.month = this.$("#reports-adhoc-month").val() || null;
    this.rebuildCalcGraph();
  },

  selectDeliveryZone: function(e) {
    e.preventDefault();

    this.dzCode = this.$("#reports-adhoc-delivery_zone").val() || null;
    this.districts = this.dzCode
      ? this.deliveryZones.get(this.dzCode).get('districts')
      : this.allDistricts;
    this.districtCode = null;
    this.rebuildCalcGraph();

    this.render();
  },

  selectDistrict: function(e) {
    e.preventDefault();

    this.districtCode = this.$("#reports-adhoc-district").val() || null;
    this.rebuildCalcGraph();
  },

  changeDefinitions: function(e) {
    e.preventDefault();

    this.definitionsJSON = this.$("#reports-adhoc-definitions-json").val();

    try {
      this.customDefinitions = JSON.parse('[' + this.definitionsJSON + ']');
      this.definitionErrors = null;
      this.rebuildCalcGraph();
    } catch(err) {
      this.definitionErrors = err;
    }

    this.render();
  },

  calculate: function(e) {
    e.preventDefault();

    // don't really want to do anything, just let ui refresh definitions
  },

  show: function(e) {
    e.preventDefault();
    e.stopPropagation();
  },

  calcDefinition: function(e, definition) {
    if (e) {
      e.preventDefault();
    }

    var definitionName = definition ? definition.name : e.target.text;

    var valueElem = this.$("#reports-adhoc-value");
    valueElem.val("calculating...");

    var that = this;
    var callback = function(result) {
      valueElem.val(result);
      that.calcGraph.off('calculated:' + definitionName, callback);
      that.$("#reports-adhoc-value").val(result);
      that.$("#reports-adhoc-value-json").html(JSON.stringify(result, undefined, 2));
    };
    this.calcGraph.on('calculated:' + definitionName, callback);
    this.calcGraph.trigger('calculate:' + definitionName);
  },

  calcMethods: {
    collection: function(values, options, callback) {
      var colCons = Collections[options.collection];
      if (!colCons) { throw 'collection not found for ' + options.collection; }
      var collection = new colCons;

      var indexedConds = null;
      if (options.conditions && options.conditions[options.index]) {
        indexedConds = {};
        indexedConds[options.index] = options.conditions[options.index];
      }

      var otherConds = _.clone(options.conditions||{});
      if (options.index) { delete otherConds[options.index]; }

      collection.fetch({
        conditions: indexedConds,
        success: function() {
          var objs = collection.toArray();
          _.each(otherConds, function(val,key) {
            objs = objs.filter(function(obj) { return obj.get(key) == val; });
          });
          callback(objs);
        },
      });
    },
  },

});
