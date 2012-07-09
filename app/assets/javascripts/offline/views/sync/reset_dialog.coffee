class Views.Sync.ResetDialog extends Backbone.View
  template: JST['offline/templates/sync/reset_dialog']

  el: '#sync-dialog'
  container: '#sync-dialog-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #reset-button': 'reset'
    'click #sync-dialog .close-dialog': -> @trigger 'dialog:close'
    'click #cancel-button': -> @trigger 'dialog:close'

  vh: Helpers.View
  t: Helpers.View.t

  render: ->
    @$(@container).html @template(@)
    @$('.background').addClass('close-dialog')
    @$el.show()
    @

  close: ->
    @undelegateEvents()
    @$el.hide()
    @unbind()

  reset: ->
    window.location = window.location.pathname.replace /\/?$/, '/reset'
