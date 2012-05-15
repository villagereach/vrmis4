class Views.Helpers.DatePicker extends Backbone.View
  template: JST['offline/templates/helpers/date_picker']

  events:
    'click .day a': 'selectDay'

  dh: Helpers.Date
  t: Helpers.View.t

  initialize: (options) ->
    @$inputElem = options.$elem
    @date = options.date
    @format = options.format

    @el = @$inputElem.attr('id') + '-picker'
    @$el = $("<div id='#{@el}' style='display:none'/>")
    @$inputElem.parent().after(@$el)

    @$inputElem.on 'focus', => @show()
    @$inputElem.on 'blur', => setTimeout (=> @hide()), 200

  render: ->
    @delegateEvents()
    @$el.html @template(@)
    @

  close: ->
    @undelegateEvents()
    @remove()
    @unbind()
    @

  show: ->
    @render()
    @$el.show()

  hide: ->
    @$el.hide()

  selectDay: (e) ->
    @date.day = Number($(e.target).text())
    @$inputElem.val(@date.format(@format))
    @$inputElem.trigger 'change'
    @hide()
