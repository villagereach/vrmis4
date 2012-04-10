Views.HcVisits.EditChildVacTally = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_child_vac_tally'],

  className: 'edit-child-vac-tally-screen',
  tabName: 'child-vac-tally',

//TARGET_GROUP_MULTIPLIERS: {
//  'bcg':     (4.0 / 12 / 100),
//  'polio0':  (3.9 / 12 / 100),
//  'polio1':  (3.9 / 12 / 100),
//  'polio2':  (3.9 / 12 / 100),
//  'polio3':  (3.9 / 12 / 100),
//  'penta1':  (3.9 / 12 / 100),
//  'penta2':  (3.9 / 12 / 100),
//  'penta3':  (3.9 / 12 / 100),
//  'measles': (3.9 / 12 / 100),
//},

//WASTAGE_RATES: [
//  { pkgCode: 'bcg',     rows: ['bcg'] },
//  { pkgCode: 'polio10', rows: ['polio0', 'polio1', 'polio2', 'polio3'] },
//  { pkgCode: 'penta1',  rows: ['penta1', 'penta2', 'penta3'] },
//  { pkgCode: 'measles', rows: ['measles'] },
//],

//recalculate: function(e, elem) {
//  if (elem || e) {
//    // called for a specific row, recalculate just that row
//    var baseId = '#' + $(elem || e.target).attr('id').replace(/-[^-]*(?:-nr)?$/, '');
//    return this.recalculateRow(baseId);

//  } else {
//    var that = this;
//    var rows = _.flatten(_(this.WASTAGE_RATES).map(function(o) { return o.rows }));
//    _.each(rows, function(row) { that.recalculateRow('#'+'hc_visit-child_vac_tally-'+row); });
//  }

//  return this;
//},

//recalculateRow: function(baseId) {
//  var that = this;
//  var target = baseId.match(/[^-]+$/)[0];
//  var baseBaseId = baseId.replace(/-[^-]*$/, '');

//  var targetMultiplier = this.TARGET_GROUP_MULTIPLIERS[target];
//  var targetGroup = this.healthCenter.get('population') * targetMultiplier;
//  this.$(baseId+'-target_group').html(Math.floor(targetGroup));

//  var values0_11 = [this.$(baseId+'-hc0_11').val(), this.$(baseId+'-mb0_11').val()];
//  var total0_11 = _.reduce(values0_11, function(m,n) { return m+(parseInt(n)||0) }, 0);
//  this.$(baseId+'-total0_11').html(total0_11);

//  var coverageRate = total0_11 / targetGroup;
//  this.$(baseId+'-coverage_rate').html(Math.floor(100 * coverageRate) + "%");

//  var values12_23 = [this.$(baseId+'-hc12_23').val(), this.$(baseId+'-mb12_23').val()];
//  var total12_23 = _.reduce(values12_23, function(m,n) { return m+(parseInt(n)||0) }, 0);
//  this.$(baseId+'-total12_23').html(total12_23);

//  var values = _.flatten([values0_11, values12_23])
//  var total = _.reduce(values, function(m,n) { return m+(parseInt(n)||0) }, 0);
//  this.$(baseId+'-total').html(total);

//  var wastage;
//  var w = _.find(this.WASTAGE_RATES, function(o) { return o.pkgCode == target || _.include(o.rows, target); });
//  var openedVials = parseInt(this.$(baseBaseId+'-'+w.pkgCode+'-opened').val());
//  if (openedVials) {
//    var pkgDoses = parseInt(this.packages.get(w.pkgCode).get('quantity')) || 1;
//    var totalVaccinations = _(w.rows)
//      .map(function(row) { return baseBaseId+'-'+row+'-total'; })
//      .map(function(id) { return parseInt(that.$(id).text()) || 0; })
//      .reduce(function(m,n) { return m+n }, 0);
//    wastage = ((openedVials * pkgDoses) - totalVaccinations) / (openedVials * pkgDoses);
//    this.$(baseBaseId+'-'+w.pkgCode+'-wastage').html(Math.floor(100 * wastage) + "%");
//  } else {
//    this.$(baseBaseId+'-'+w.pkgCode+'-wastage').html('');
//  }

//  return this;
//},

});
