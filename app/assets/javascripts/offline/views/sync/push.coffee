class Views.Sync.Push extends Backbone.View
  template: JST['offline/templates/sync/push']

  el: '#sync-dialog'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #push': 'push'

  initialize: (options) ->
    @[k] = v for k,v of options

  render: ->
    @$el.html @template(@)
    @

  push: ->
    @pushResults = @syncState.push()
    @pushResults.on 'pushed:hcVisit pushed:warehouseVisit', =>
      @syncState.save()
      @render()
