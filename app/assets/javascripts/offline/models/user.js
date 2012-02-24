Models.User = Backbone.Model.extend({
  defaults: {
    accessCode: null,
  },

  login: function(accessCode) {
    if (!this.get('accessCode')) { return false; }
    if (this.get('accessCode') != accessCode) { return false; }
    this.trigger('login');
    return true;
  }
});
