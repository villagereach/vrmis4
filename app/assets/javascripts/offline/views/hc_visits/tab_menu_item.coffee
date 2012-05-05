class Views.HcVisits.TabMenuItem extends Backbone.View
  template: JST['offline/templates/hc_visits/tab_menu_item']

  tagName: 'li'
  className: 'tab-menu-item'

  vh: Helpers.View
  t: Helpers.View.t

  events:
    'click .select-tab': 'triggerSelect'

  initialize: (options) ->
    @selected = options.selected
    @tabName = options.tabName
    @state = options.state

  render: ->
    @delegateEvents()
    @$el.html @template(@)
    @$el.addClass(@state)
    @$el.addClass('selected') if @selected
    @

  close: ->
    @undelegateEvents()
    @unbind()

  triggerSelect: ->
    @trigger('select:tab', @tabName)

  select: ->
    @selected = true
    @$el.addClass('selected')

  deselect: ->
    @selected = false
    @$el.removeClass('selected')

  setState: (state) ->
    @$el.removeClass(@state).addClass(state)
    @state = state

  disabled: ->
    state is 'disabled'
