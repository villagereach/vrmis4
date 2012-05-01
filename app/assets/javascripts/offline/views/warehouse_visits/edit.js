Views.WarehouseVisits.Edit = Backbone.View.extend({
  template: JST['offline/templates/warehouse_visits/form'],
  tableField: JST['offline/templates/warehouse_visits/table_field'],

  el: '#offline-container',
  state: null, // starting state is unknown

  events: {
    'change input, textarea': 'change',
  },

  vh: Helpers.View,
  t: Helpers.View.t,

  initialize: function(options) {
    var that = this;
    _.each(options, function(v,k) { that[k] = v });

    this.districts = this.deliveryZone.get('districts');
    this.healthCenters = this.deliveryZone.get('healthCenters');
    this.productTypes = ['vaccine', 'syringe', 'test', 'safety', 'fuel'];

    var that = this;
    this.pkgsByType = {};
    _.each(this.productTypes, function(type) {
      var pkgs = options.packages.filter(function(p) { return p.get('product_type') == type });
      that.pkgsByType[type] = new Collections.Packages(pkgs);
    });

    this.idealStock = {};
    options.packages.each(function(pkg) {
      var pkgCode = pkg.get('code');
      that.idealStock[pkgCode] = that.healthCenters.sum('ideal_stock_amounts.' + pkgCode);
    });
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template(this));
    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
    return this;
  },

  change: function(e) {
    var elem = e.target;
    var $elem = this.$(elem);

    var obj = this.warehouseVisit;
    var type = elem.type;
    var name = elem.name;
    var value = null;

    if (type == 'number') {
      value = Number(elem.value).toString() === elem.value
        ? Number(elem.value)
        : null;
      obj.set(name, value);

    } else {
      value = elem.value;
      if (value === '') { value = null; }
      obj.set(name, value);
    }

    this.validateElement(elem, value);

    this.refreshState();

    return [name, value];
  },

  validateElement: function(elem, value) {
    var $xElem = this.$('[id="' + elem.name + '-x"]');
    if (value != null && value !== '' && !(_.isArray(value) && _.isEmpty(value))) {
      $xElem.removeClass('x-invalid').addClass('x-valid');
    } else {
      $xElem.removeClass('x-valid').addClass('x-invalid');
    }
  },

  refreshState: function(newState) {
    newState = newState ? newState
      : this.$(".x-invalid").length == 0 ? 'complete'
      : this.$(".x-valid").length == 0 ? 'todo'
      : 'incomplete';

    if (this.state != newState) {
      this.state = newState;
      this.trigger('change:state', newState);
    }
  },

  setSuper: function(klass) { this.super = klass },

});

// hackish way of setting 'super' class to make subclassed functions cleaner
Views.WarehouseVisits.Edit.prototype.setSuper(Views.WarehouseVisits.Edit.prototype);
