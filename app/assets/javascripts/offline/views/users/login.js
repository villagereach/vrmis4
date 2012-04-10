Views.Users.Login = Backbone.View.extend({
  template: JST["offline/templates/users/login"],

  el: "#offline-container",

  events: {
    "submit":        "login",
    "click .submit": "login",
  },

  vh: Helpers.View,
  t: Helpers.View.t,

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template(this));
    this.$("#user-access_code").focus();

    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.unbind();
  },

  login: function(e) {
    e.preventDefault();
    e.stopPropagation();

    var accessCode = this.$("#user-access_code").val();
    var user = this.collection.find(function(u) { return u.login(accessCode); });

    if (user) {
      this.trigger("login", user);
      return true;
    } else {
      this.render();
      this.$(".form-errors").show();
      return false;
    }
  },

});
