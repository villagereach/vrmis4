class Views.Sync.ProgressDialog extends Backbone.View
  template: JST['offline/templates/sync/progress_dialog']

  el: '#sync-dialog'
  container: '#sync-dialog-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click .close-dialog': -> @trigger 'dialog:close'

  vh: Helpers.View
  t: Helpers.View.t

  initialize: (options) ->
    @[k] = v for k,v of options

  render: ->
    @$(@container).html @template(@)
    @$('.push-visits').addClass('disabled') unless @pushVisits
    @$('.check-updates').addClass('disabled') unless @checkUpdates
    @$('.pull-data').addClass('disabled') unless @pullData

    @$el.show()
    @

  close: ->
    @undelegateEvents()
    @$el.hide()
    @unbind()

  start: ->
    @performStep '.push-visits', @pushVisits, =>
      @performStep '.check-updates', @checkUpdates, =>
        @performStep '.pull-data', @pullData, =>
          @$('.done').addClass('active')
          @allowClose()

  performStep: (stepElem, workerCallback, nextStep) ->
    return nextStep() unless workerCallback

    $stepElem = @$(stepElem)
    $stepElem.addClass('active')
    $progressElem = $stepElem.children('.step-progress')

    workerCallback
      $elem: $progressElem,
      success: =>
        $progressElem.text()
        $stepElem.removeClass('active').addClass('complete')
        nextStep()
      error: =>
        $stepElem.removeClass('active').addClass('error')
        @allowClose()

  allowClose: ->
    @$('.close-dialog').show()
    @$('.background').addClass('close-dialog')
