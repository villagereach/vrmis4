Views.HcVisits.EditAdultVacTally = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_adult_vac_tally'],

  className: 'edit-adult-vac-tally-screen',
  tabName: 'adult-vac-tally',

  events: _.extend(_.clone(Views.HcVisits.EditScreen.prototype.events), {
    'change .calculate' : 'recalculate',
  }),

  TARGET_GROUP_MULTIPLIERS: {
    'w_pregnant': (5.0 / 12 / 100),
    'student':    (5.0 / 12 / 100),
    'labor':      (5.0 / 12 / 100),
  },

  WASTAGE_RATES: [
    { pkgCode: 'tetanus',
      rows: [ 'w_pregnant', 'w_15_49_community', 'w_15_49_student',
              'w_15_49_labor', 'student', 'labor', 'other' ],
    },
  ],

  render: function() {
    this.super.render.apply(this, arguments);
    this.recalculate();
    return this;
  },

  recalculate: function(e, elem) {
    if (elem || e) {
      // called for a specific row, recalculate just that row
      var baseId = '#' + $(elem || e.target).attr('id').replace(/-[^-]*(?:-nr)?$/, '');
      return this.recalculateRow(baseId);

    } else {
      var that = this;
      var rows = _.flatten(_(this.WASTAGE_RATES).map(function(o) { return o.rows }));
      _.each(rows, function(row) { that.recalculateRow('#'+'hc_visit-adult_vac_tally-'+row); });
    }

    return this;
  },

  recalculateRow: function(baseId) {
    var that = this;
    var target = baseId.match(/[^-]+$/)[0];
    var baseBaseId = baseId.replace(/-[^-]*$/, '');

    var targetMultiplier = this.TARGET_GROUP_MULTIPLIERS[target];
    if (targetMultiplier) {
      var targetGroup = this.healthCenter.get('population') * targetMultiplier;
      this.$(baseId+'-target_group').html(Math.floor(targetGroup));
    }

    var values1 = [this.$(baseId+'-tet1hc').val(), this.$(baseId+'-tet1mb').val()];
    var total1 = _.reduce(values1, function(m,n) { return m+(parseInt(n)||0) }, 0);
    this.$(baseId+'-tet1total').html(total1);

    var values2_5 = [this.$(baseId+'-tet2_5hc').val(), this.$(baseId+'-tet2_5mb').val()];
    var total2_5 = _.reduce(values2_5, function(m,n) { return m+(parseInt(n)||0) }, 0);
    this.$(baseId+'-tet2_5total').html(total2_5);

    var values = _.flatten([values1, values2_5])
    var total = _.reduce(values, function(m,n) { return m+(parseInt(n)||0) }, 0);
    this.$(baseId+'-total').html(total);

    var coverageRate = target == 'w_pregnant'
      ? total1 / targetGroup
      : (total1 + total2_5) / targetGroup;
    this.$(baseId+'-coverage_rate').html(Math.floor(100 * coverageRate) + "%");

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

    // totals across bottom of screen
    var tet1hc = _(w.rows)
      .map(function(row) { return parseInt(that.$(baseBaseId+'-'+row+'-tet1hc').val()) || 0; })
      .reduce(function(m,n) { return m+n }, 0);
    this.$(baseBaseId+'-tet1hc-total').html(tet1hc);

    var tet1mb = _(w.rows)
      .map(function(row) { return parseInt(that.$(baseBaseId+'-'+row+'-tet1mb').val()) || 0; })
      .reduce(function(m,n) { return m+n }, 0);
    this.$(baseBaseId+'-tet1mb-total').html(tet1mb);

    var tet1total = tet1hc + tet1mb;
    this.$(baseBaseId+'-tet1total-total').html(tet1total);

    var tet2_5hc = _(w.rows)
      .map(function(row) { return parseInt(that.$(baseBaseId+'-'+row+'-tet2_5hc').val()) || 0; })
      .reduce(function(m,n) { return m+n }, 0);
    this.$(baseBaseId+'-tet2_5hc-total').html(tet2_5hc);

    var tet2_5mb = _(w.rows)
      .map(function(row) { return parseInt(that.$(baseBaseId+'-'+row+'-tet2_5mb').val()) || 0; })
      .reduce(function(m,n) { return m+n }, 0);
    this.$(baseBaseId+'-tet2_5mb-total').html(tet2_5mb);

    var tet2_5total = tet2_5hc + tet2_5mb;
    this.$(baseBaseId+'-tet2_5total-total').html(tet2_5total);

    this.$(baseBaseId+'-total-total').html(tet1total + tet2_5total);

    return this;
  },

});
