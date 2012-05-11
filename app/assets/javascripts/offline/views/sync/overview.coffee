class Views.Sync.Overview extends Backbone.View
  template: JST['offline/templates/sync/overview']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #check-online': 'checkOnline'
    'click #push-visits': 'pushVisitsDialog'
    'click #pull-data': -> @progressDialog(['checkUpdates','pullData'])

  vh: Helpers.View
  t: Helpers.View.t

  initialize: (options) ->
    @[k] = v for k,v of options

  render: ->
    @readyHcVisits ?= @dirtyHcVisits.filter (hcv) => hcv.get('state') is 'complete'
    @readyWarehouseVisits ?= @dirtyWarehouseVisits.filter (wv) => wv.get('state') is 'complete'

    @$el.html @template(@)
    @checkOnline()
    @

  close: ->
    @undelegateEvents()
    @unbind()

  checkOnline: ->
    $elem = @$('#online-status')
    $elem.removeClass('online').removeClass('offline')
    $elem.children('.message').text @t('offline.sync.overview.checking')

    @syncState.checkOnline
      success: => $elem.addClass('online').children('.message').text(@t('offline.sync.overview.online'))
      error: => $elem.addClass('offline').children('.message').text(@t('offline.sync.overview.offline'))

  pushVisitsDialog: ->
    @$('#push-visits').hide()

    loginDialog = new Views.Sync.LoginDialog
    loginDialog.on 'dialog:close', =>
      loginDialog.close()
      @$('#push-visits').show()
    loginDialog.on 'login:success', (credentials) =>
      loginDialog.close()
      @progressDialog ['pushVisits', 'checkUpdates', 'pullData']

    loginDialog.render()

  progressDialog: (steps, credentials) ->
    available =
      pushVisits: (options) =>
        (status = @syncState.push(credentials)).on 'pushed:all', =>
          @logout()
          options.success()
      checkUpdates: (options) =>
        @syncState.update
          mode: App.mode
          success: =>
            @trigger 'navigate', '#sync/pull', false
            window.location.reload(true)
          error: (e) =>
            options.error()
      pullData: (options) =>
        (status = @syncState.pull()).on 'pulled:all', =>
          options.success()

    dialog = new Views.Sync.ProgressDialog
      pushVisits: if _.include(steps, 'pushVisits') then available.pushVisits else null
      checkUpdates: if _.include(steps, 'checkUpdates') then available.checkUpdates else null
      pullData: if _.include(steps, 'pullData') then available.pullData else null
    dialog.on 'dialog:close', =>
      dialog.close()
      @readyHcVisits = @readyWarehouseVisits = null
      @render()

    dialog.render()
    dialog.start()

  logout: ->
    $.ajax
      url: "#{App.baseUrl}/login"
      username: 'reset',
      password: 'reset',
