class Views.HcVisits.Container extends Backbone.View
  template: JST['offline/templates/hc_visits/container']
  screenNavTemplate: JST['offline/templates/hc_visits/screen_nav']

  el: '#offline-container'

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click .next-tab' : 'nextTab'
    'click .prev-tab' : 'prevTab'

  vh: Helpers.View
  dh: Helpers.Date
  t: Helpers.View.t

  initialize: (options) ->
    @[k] = v for k,v of options

    @tabs = []
    @screens = []
    @screenIdx = -1
    @currentTab = null

    @on('select:tab', @selectTab)

  render: ->
    @$el.html @template(@)
    @$('.tab-menu ul').append(@tabs.map (t) -> t.render().el)
    @selectTab(@currentTab)
    @

  close: ->
    @screens.forEach (s) -> s.close
    @tabs.forEach (t) -> t.close
    @undelegateEvents()
    @unbind()

  addScreen: (tabName, screen) ->
    tab = new Views.HcVisits.TabMenuItem
      tabName: screen.tabName
      state: screen.state

    tab.on 'all', => @trigger.apply(@, arguments)

    pos = @tabs.push(tab)
    screen.screenPos = pos
    @screens.push(screen)

    unless @currentTab
      @currentTab = tabName
      @screenIdx = pos - 1
      tab.selected = true

    tab

  selectTab: (tabName) ->
    if tabName != @currentTab
      @tabs[@screenIdx].deselect()
      for tab, idx in @tabs when tab.tabName is tabName
        tab.select()
        @currentTab = tabName
        @screenIdx = idx
        break

    if @screenIdx >= 0
      @$('.tab-screen').html(@screens[@screenIdx].render().el)
      @$('.tab-nav-links').html(@screenNavTemplate(@))

    @trigger('navigate', "hc_visits/#{@hcVisit.get('code')}/#{tabName}", false)

  hasPrevTab: ->
    return false if @screenIdx - 1 < 0
    prev = _(@screens).first(@screenIdx).reverse().filter((s) -> s.state != 'disabled')[0]
    prev?

  hasNextTab: ->
    next = _(@screens).rest(@screenIdx + 1).filter((s) -> s.state != 'disabled')[0]
    next?

  prevTab: ->
    return false if @screenidx - 1 < 0
    prev = _(@screens).first(@screenIdx).reverse().filter((s) -> s.state != 'disabled')[0]
    @selectTab prev?.tabName

  nextTab: ->
    next = _(@screens).rest(@screenIdx + 1).filter((s) -> s.state != 'disabled')[0]
    @selectTab next?.tabName
