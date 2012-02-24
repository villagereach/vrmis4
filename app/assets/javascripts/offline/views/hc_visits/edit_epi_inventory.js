Views.HcVisits.EditEpiInventory = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_epi_inventory"],

  tagName: "div",
  className: "edit-epi-inventory-screen",
  tabName: "tab-epi-inventory",
  state: "todo",

  events: {
    "change .number": "numberChange",
    "click .nr":      "nrChange",
  },

  initialize: function(options) {
    this.packages = new Collections.Packages(
      options.packages.filter(function(p) {
        return p.get('product').get('product_type') != 'test';
      })
    );

    var epiInventory = this.model.get('epi_inventory') || {};
    _.each(this.packages.pluck('code'), function(pkgCode) {
      epiInventory[pkgCode] = epiInventory[pkgCode] || {};

      var ideal = _.find(options.idealStockAmounts, function(a) {
        return a.package_code == pkgCode
      });

      if (epiInventory[pkgCode].ideal == null) {
        epiInventory[pkgCode].ideal = ideal.quantity;
      }
    });

    this.model.set('epi_inventory', epiInventory);

    var that = this;
    this.model.on('change:visited', function() {
      that.refreshState();
      that.trigger('refresh:tabs');
    });

    if (this.model.get('visited') === false) { this.state = 'disabled' }
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template({
      packages: this.packages.toJSON(),
      epiInventory: this.model.get('epi_inventory'),
    }));

    this.validate();
    this.refreshState();

    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.remove();
    this.unbind();
  },

  nrChange: function(e) {
    var elem = e.srcElement;

    var $inputField = this.$('#' + elem.id.slice(0, -3)); // removes trailing "-nr"
    if (elem.checked) { $inputField.val(null); }

    this.change(e, $inputField[0]);
  },

  numberChange: function(e) {
    var elem = e.srcElement;

    var $nrCheckbox = this.$('#' + elem.id + '-nr');
    if ($nrCheckbox.attr('checked')) { $nrCheckbox.attr('checked', false); }

    this.change(e, elem);
  },

  change: function(e, elem) { // where elem is the real element, not NR boxes
    elem = elem || e.srcElement;

    var attrs = this.serialize();
    this.model.set('epi_inventory', attrs.epi_inventory);

    this.validateElement(e, elem);
    this.refreshState();
  },

  serialize: function() {
    var attrs = this.$("form").toObject({ skipEmpty: false, emptyToNull: true });

    // poplulate epi_inventory values w/ NR for all checked NR boxes
    var epiInventory = attrs.epi_inventory;
    var nrVals = attrs.nr.epi_inventory;
    _.each(epiInventory, function(categories,code) {
      _.each(categories, function(qty, category) {
        if (nrVals[code][category]) { epiInventory[code][category] = 'NR'; }
      });
    });

    return { epi_inventory: epiInventory };
  },

  validate: function() {
    var that = this;
    this.$(".validate").each(function(idx,elem) { that.validateElement(null, elem); });
  },

  validateElement: function(e, elem) {
    elem = elem || e.srcElement;
    if (!this.$(elem).hasClass("validate")) { return; }

    // add additional statements for special cases here

    // NOTE: currently going off model, which requires updating model first
    // as it was going to require dealing with radio/checkboxes/etc otherwise

    if (this.model.deepGet(elem.name)) {
      this.$('#'+elem.id+'-x').removeClass('x-invalid').addClass('x-valid');
      return;
    } else {
      this.$('#'+elem.id+'-x').removeClass('x-valid').addClass('x-invalid');
      return "is invalid";
    }
  },

  refreshState: function(e) {
    this.state = this.checkState();
    return this;
  },

  checkState: function(e) {
    if (!this.model.get("visited")) { return "disabled"; }
    if (this.$(".x-invalid").length == 0) return "complete";
    if (this.$(".x-valid").length == 0) return "todo";
    return "incomplete";
  },

});
