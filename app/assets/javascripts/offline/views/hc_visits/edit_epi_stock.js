Views.HcVisits.EditEpiStock = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_epi_stock"],

  tagName: "div",
  className: "edit-epi-stock-screen",
  tabName: "tab-epi-stock",
  state: "todo",

  events: {
    "change .input":     "inputChange",
    "click .nr":         "nrChange",
    "change .calculate": "recalculate",
    "click .calculate":  "recalculate",
  },

  initialize: function(options) {
    this.products = new Collections.Products(
      options.products.filter(function(p) {
        return p.get('product_type') == 'vaccine';
      })
    );

    if (!this.model.get('epi_stock')) {
      this.model.set('epi_stock', {});
    }

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
      products: this.products.toJSON(),
      epiStock: this.model.get('epi_stock'),
    }));

    this.validate();
    this.refreshState();
    this.recalculate();

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

  inputChange: function(e) {
    var elem = e.srcElement;

    var $nrCheckbox = this.$('#' + elem.id + '-nr');
    if ($nrCheckbox.attr('checked')) { $nrCheckbox.attr('checked', false); }

    this.change(e, elem);
  },

  change: function(e, elem) { // where elem is the real element, not NR boxes
    elem = elem || e.srcElement;

    var attrs = this.serialize();
    this.model.set('epi_stock', attrs.epi_stock);

    this.validateElement(e, elem);
    this.refreshState();
  },

  serialize: function() {
    var attrs = this.$("form").toObject({ skipEmpty: false, emptyToNull: true });

    // poplulate epi_stock values w/ NR for all checked NR boxes
    var epiStock = attrs.epi_stock;
    var nrVals = attrs.nr.epi_stock;
    _.each(epiStock, function(categories,code) {
      _.each(categories, function(qty, category) {
        if (nrVals[code][category]) { epiStock[code][category] = 'NR'; }
      });
    });

    return { epi_stock: epiStock };
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

    var value = this.model.deepGet(elem.name);
    if (value != null) {
      this.$('#'+elem.id+'-x').removeClass('x-invalid').addClass('x-valid');
      return;
    } else {
      this.$('#'+elem.id+'-x').removeClass('x-valid').addClass('x-invalid');
      return "is invalid";
    }
  },

  recalculate: function() {
    var that = this;
    this.$('.calculated').each(function() {
      var baseId = '#' + $(this).attr('id').replace(/total$/, '');
      var values = [that.$(baseId+'first_of_month').val(), that.$(baseId+'received').val()]
      $(this).html(_.reduce(values, function(m,n) { return m+(parseInt(n)||0) }, 0));
    });

    return this;
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
