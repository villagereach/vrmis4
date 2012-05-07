class Views.Users.Login extends Backbone.View
  template: JST['offline/templates/users/login']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click .login': 'login'

  vh: Helpers.View
  t: Helpers.View.t

  render: ->
    @delegateEvents()
    @$el.html this.template(@)
    @$('#user-access_code').focus()
    @

  close: ->
    @undelegateEvents()
    @unbind()

  login: ->
    window.console.log 'attempting login...'
    password = @$('#user-access_code').val()
    user = @collection.find (u) => u.login(password)
    if user then @trigger('login', user) else @$('.form-errors').show()
    user?
