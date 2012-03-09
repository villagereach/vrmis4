Views.Users.Sync = Backbone.View.extend({
  template: JST["offline/templates/users/sync"],

  el: "#offline-container",
  pullResults: {
    products: 'unknown',
    deliveryZones: 'unknown',
    healthCenters: 'unknown',
    hcVisits: 'unknown',
  },

  events: {
    "click #sync-pull": "pullData",
  },

  initialize: function(options) {
  },

  render: function() {
    this.$el.html(this.template({
      pullResults: this.pullResults
    }));
    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
  },

  pullData: function(e) {
    e.preventDefault();

    var that = this;
    this.pullResults = this.model.pull({
      success: function() {

      },
    });
    this.pullResults.on('pulled:products pulled:deliveryZones pulled:healthCenters pulled:hcVisits', this.render, this);
  },

});
