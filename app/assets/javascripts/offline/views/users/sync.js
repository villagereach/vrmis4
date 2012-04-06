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
    "click #sync-push": "pushData",
  },

  initialize: function(options) {
    var that = this;
    App.dirtyHcVisits.fetch({ success: function() { that.render() } });
  },

  render: function() {
    var states = App.dirtyHcVisits.map(function(v) { return v.get('state') });
    var dirtyCounts = _.reduce(states, function(counts, state) {
      counts.total = (counts.total || 0) + 1;
      counts[state] = (counts[state] || 0) + 1;
      return counts;
    }, {});

    this.$el.html(this.template({
      pullResults: this.pullResults,
      dirtyCounts: { hcVisits: dirtyCounts.complete || 0 },
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
    this.pullResults = this.model.pull();
    this.pullResults.on('pulled:products pulled:deliveryZones pulled:healthCenters pulled:hcVisits', this.render, this);
  },

  pushData: function(e) {
    e.preventDefault();

    var that = this;
    this.pushResults = this.model.push();
    this.pushResults.on('pushed:hcVisit', this.render, this);
  },

});
