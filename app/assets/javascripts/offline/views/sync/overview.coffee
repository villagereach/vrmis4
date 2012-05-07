class Views.Sync.Overview extends Backbone.View
  template: JST['offline/templates/sync/overview']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #check-online': 'checkOnline'
    'click #push-visits': 'pushVisitsDialog'
    'click #pull-data': 'pullDataDialog'

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
    $elem.children('.message').text 'Checking online status...'

    @syncState.checkOnline
      success: => $elem.addClass('online').children('.message').text('ONLINE')
      error: => $elem.addClass('offline').children('.message').text('OFFLINE')

  pushVisitsDialog: ->
    @$('#push-visits').hide()

    loginDialog = new Views.Sync.LoginDialog
    loginDialog.on 'dialog:close', =>
      loginDialog.close()
      @$('#push-visits').show()
    loginDialog.on 'login:success', (credentials) =>
      loginDialog.close()

      progressDialog = new Views.Sync.ProgressDialog
        pushVisits: (options) =>
          (status = @syncState.push(credentials)).on 'pushed:all', =>
            options.success()
        pullData: (options) =>
          (status = @syncState.pull()).on 'pulled:all', =>
            options.success()
      progressDialog.on 'dialog:close', =>
        progressDialog.close()
        @readyHcVisits = @readyWarehouseVisits = null
        @render()

      progressDialog.render()
      progressDialog.start()

    loginDialog.render()

  pullDataDialog: ->
    progressDialog = new Views.Sync.ProgressDialog
      pullData: (options) =>
        (status = @syncState.pull()).on 'pulled:all', =>
          options.success()
    progressDialog.on 'dialog:close', =>
      progressDialog.close()
      @readyHcVisits = @readyWarehouseVisits = null
      @render()

    progressDialog.render()
    progressDialog.start()
