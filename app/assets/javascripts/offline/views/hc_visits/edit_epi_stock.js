Views.HcVisits.EditEpiStock = Views.HcVisits.EditScreen.extend({
  template: JST['offline/templates/hc_visits/edit_epi_stock'],

  className: 'edit-epi-stock-screen',
  tabName: 'epi-stock',

  events: _.extend(_.clone(Views.HcVisits.EditScreen.prototype.events), {
    'change .calculate' : 'recalculate',
  }),

  initialize: function(options) {
    this.super.initialize.apply(this, arguments);

    this.products = new Collections.Products(
      options.products.filter(function(p) {
        return p.get('product_type') == 'vaccine';
      })
    );
  },

  render: function() {
    this.super.render.apply(this, arguments);
    this.recalculate();
    return this;
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

});
