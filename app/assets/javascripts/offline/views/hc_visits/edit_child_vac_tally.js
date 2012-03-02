Views.HcVisits.EditChildVacTally = Backbone.View.extend({
  template: JST["offline/templates/hc_visits/edit_child_vac_tally"],

  TARGET_GROUP_MULTIPLIERS: {
    'bcg':     (4.0 / 12 / 100),
    'polio0':  (3.9 / 12 / 100),
    'polio1':  (3.9 / 12 / 100),
    'polio2':  (3.9 / 12 / 100),
    'polio3':  (3.9 / 12 / 100),
    'penta1':  (3.9 / 12 / 100),
    'penta2':  (3.9 / 12 / 100),
    'penta3':  (3.9 / 12 / 100),
    'measles': (3.9 / 12 / 100),
  },

  WASTAGE_RATES: [
    { pkgCode: 'bcg',     rows: ['bcg'] },
    { pkgCode: 'polio10', rows: ['polio0', 'polio1', 'polio2', 'polio3'] },
    { pkgCode: 'penta1',  rows: ['penta1', 'penta2', 'penta3'] },
    { pkgCode: 'measles', rows: ['measles'] },
  ],

  tagName: "div",
  className: "edit-child-vac-tally-screen",
  tabName: "tab-child-vac-tally",
  state: "todo",

  events: {
    "change .input":  "inputChange",
    "click .nr":      "nrChange",
    "change .calculate": "recalculate",
    "click .calculate":  "recalculate",
  },

  initialize: function(options) {
    var that = this;

    this.healthCenter = options.healthCenter;
    this.packages = options.packages;

    this.model.on('change:visited', function() {
      that.refreshState();
      that.trigger('refresh:tabs');
    });

    if (this.model.get('visited') === false) { this.state = 'disabled' }
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template({
      childVacTally: (this.model.get('child_vac_tally') || {}),
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
    this.model.set('child_vac_tally', attrs.child_vac_tally);

    this.validateElement(e, elem);
    this.refreshState();
  },

  serialize: function() {
    var attrs = this.$("form").toObject({ skipEmpty: false, emptyToNull: true });

    // poplulate child_vac_tally values w/ NR for all checked NR boxes
    var childVacTally = attrs.child_vac_tally;
    var nrVals = attrs.nr.child_vac_tally;
    _.each(childVacTally, function(categories,code) {
      _.each(categories, function(qty, category) {
        if (nrVals[code][category]) { childVacTally[code][category] = 'NR'; }
      });
    });

    return { child_vac_tally: childVacTally };
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

  recalculate: function(e, elem) {
    if (elem || e) {
      // called for a specific row, recalculate just that row
      var baseId = '#' + $(elem || e.srcElement).attr('id').replace(/-[^-]*(?:-nr)?$/, '');
      return this.recalculateRow(baseId);

    } else {
      var that = this;
      var rows = _.flatten(_(this.WASTAGE_RATES).map(function(o) { return o.rows }));
      _.each(rows, function(row) { that.recalculateRow('#'+'hc_visit-child_vac_tally-'+row); });
    }

    return this;
  },

  recalculateRow: function(baseId) {
    var that = this;
    var target = baseId.match(/[^-]+$/)[0];
    var baseBaseId = baseId.replace(/-[^-]*$/, '');

    var targetMultiplier = this.TARGET_GROUP_MULTIPLIERS[target];
    var targetGroup = this.healthCenter.get('population') * targetMultiplier;
    this.$(baseId+'-target_group').html(Math.floor(targetGroup));

    var values0_11 = [this.$(baseId+'-hc0_11').val(), this.$(baseId+'-mb0_11').val()];
    var total0_11 = _.reduce(values0_11, function(m,n) { return m+(parseInt(n)||0) }, 0);
    this.$(baseId+'-total0_11').html(total0_11);

    var coverageRate = total0_11 / targetGroup;
    this.$(baseId+'-coverage_rate').html(Math.floor(100 * coverageRate) + "%");

    var values12_23 = [this.$(baseId+'-hc12_23').val(), this.$(baseId+'-mb12_23').val()];
    var total12_23 = _.reduce(values12_23, function(m,n) { return m+(parseInt(n)||0) }, 0);
    this.$(baseId+'-total12_23').html(total12_23);

    var values = _.flatten([values0_11, values12_23])
    var total = _.reduce(values, function(m,n) { return m+(parseInt(n)||0) }, 0);
    this.$(baseId+'-total').html(total);

    var wastage;
    var w = _.find(this.WASTAGE_RATES, function(o) { return o.pkgCode == target || _.include(o.rows, target); });
    var openedVials = parseInt(this.$(baseBaseId+'-'+w.pkgCode+'-opened').val());
    if (openedVials) {
      var pkgDoses = parseInt(this.packages.get(w.pkgCode).get('quantity')) || 1;
      var totalVaccinations = _(w.rows)
        .map(function(row) { return baseBaseId+'-'+row+'-total'; })
        .map(function(id) { return parseInt(that.$(id).text()) || 0; })
        .reduce(function(m,n) { return m+n }, 0);
      wastage = ((openedVials * pkgDoses) - totalVaccinations) / (openedVials * pkgDoses);
      this.$(baseBaseId+'-'+w.pkgCode+'-wastage').html(Math.floor(100 * wastage) + "%");
    } else {
      this.$(baseBaseId+'-'+w.pkgCode+'-wastage').html('');
   }

    return this;
  },

  refreshState: function(e) {
    this.state = this.checkState();
    return this;
  },

  checkState: function(e) {
    if (this.$(".x-invalid").length == 0) return "complete";
    if (this.$(".x-valid").length == 0) return "todo";
    return "incomplete";
  },

});
