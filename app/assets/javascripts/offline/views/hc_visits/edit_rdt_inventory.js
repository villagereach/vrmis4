Views.HcVisits.EditRdtInventory = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_rdt_inventory"],

  tagName: "div",
  className: "edit-rdt-inventory-screen",
  tabName: "tab-rdt-inventory",
  state: "todo",

  events: {
    "change .number": "numberChange",
    "click .nr":      "nrChange",
  },

  initialize: function(options) {
    this.packages = new Collections.Packages(
      options.packages.filter(function(p) {
        return p.get('product').get('product_type') == 'test';
      })
    );

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
      rdt_inventory: (this.model.get('rdt_inventory') || {}),
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
    this.model.set('rdt_inventory', attrs.rdt_inventory);

    this.validateElement(e, elem);
    this.refreshState();
  },

  serialize: function() {
    var attrs = this.$("form").toObject({ skipEmpty: false, emptyToNull: true });

    // poplulate rdt_inventory values w/ NR for all checked NR boxes
    var rdtInventory = attrs.rdt_inventory;
    var nrVals = attrs.nr.rdt_inventory;
    _.each(rdtInventory, function(categories,code) {
      _.each(categories, function(qty, category) {
        if (nrVals[code][category]) { rdtInventory[code][category] = 'NR'; }
      });
    });

    return { rdt_inventory: rdtInventory };
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
