Views.Reports.Adhoc = Backbone.View.extend({
  template: JST["offline/templates/reports/adhoc"],
  json_template: JST['offline/templates/reports/_json_output'],

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
  ],

  initialize: function(options) {
    this.months = options.months;
    this.deliveryZones = App.deliveryZones;
    this.districts = App.districts;
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

    this.definitions = _.union(this.defaultDefinitions, [
      { name:       'hcVisits',
        method:     'collection',
        collection: 'HcVisits',
        index:      'month',
        conditions: hcvConditions
      },
      { name:       'healthCenters',
        method:     'collection',
        collection: 'HealthCenters',
        conditions: conditions
      },
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
      : App.districts;
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

    var definitionName = definition ? definition.name : e.srcElement.text;

    var valueElem = this.$("#reports-adhoc-value");
    valueElem.val("calculating...");

    var that = this;
    var callback = function(result) {
      valueElem.val(result);
      that.calcGraph.off('calculated:' + definitionName, callback);
      that.$("#reports-adhoc-value").val(result);
      that.$("#reports-adhoc-value-json").html(that.json_template({data: that.print_json(result)}));
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
  
  print_json: function(obj) {
    var html = '';
    
    if (typeof obj === "object") {
      for(var key in obj) {
        html = html + '<dt>' + obj[key] + '</dt>';
        // TODO: refactor due to stack exceeded for even modest sized objects
        this.print_json(obj[key]);
      }
    } else {
      html = html + '<dd>' + obj + '</dd>';
    }
    
    return html;
  },

});
