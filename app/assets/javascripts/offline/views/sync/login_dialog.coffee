class Views.Sync.LoginDialog extends Backbone.View
  template: JST['offline/templates/sync/login_dialog']

  el: '#sync-dialog'
  container: '#sync-dialog-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #login-button': 'login'
    'click #sync-dialog .close-dialog': -> @trigger 'dialog:close'

  initialize: (options) ->
    @passwordField = (Math.floor(Math.random()*26+10).toString(36) for [1..16]).join('')

  render: ->
    @$(@container).html @template(@)
    @$('.background').addClass('close-dialog')
    @$el.show()
    @$('input[name=username]').focus()
    @

  close: ->
    @undelegateEvents()
    @$el.hide()
    @unbind()

  login: ->
    $usernameElem = @$('input[name=username]')
    $passwordElem = @$("input[name=#{@passwordField}]")
    username = $usernameElem.val() || 'invalid'
    password = $passwordElem.val() || 'invalid'
    $.ajax
      url: "#{App.baseUrl}/login"
      username: username,
      password: password,
      success: => @trigger 'login:success', { username: username, password: password }
      error: (jqxhr, status) =>
        $passwordElem.val('')
        (if $usernameElem.val() then $passwordElem else $usernameElem).focus()
        @$('.form-errors').show().children().hide()
        if jqxhr.status is 420
          @$('.invalid-auth').show()
        else
          @$('.unknown-error').show()
