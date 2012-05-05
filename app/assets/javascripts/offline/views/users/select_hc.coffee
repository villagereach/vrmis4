class Views.Users.SelectHc extends Backbone.View
  template: JST['offline/templates/users/fc_select_hc']
  el: '#offline-container'
  vh: Helpers.View
  t: Helpers.View.t

  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'change #fc-health_center-search': 'filterHcSelection'

  initialize: (options) ->
    @visitMonth = options.month
    @deliveryZone = options.deliveryZone
    @districts = @deliveryZone.get('districts')
    @hcVisits = options.hcVisits
    @dirtyHcVisits = options.dirtyHcVisits

  render: () ->
    @delegateEvents()
    @$el.html @template(@)
    $('#fc-health_center-search').focus(-> $(@).select()).focus()

  close: () =>
    @undelegateEvents()
    @unbind()

  filterHcSelection: (e) ->
    if searchText = @$(e.target).val()
      @$('#hc_list li').hide()
      jQuery.expr[':'].Contains = (a, i, m) ->
        (a.textContent || a.innerText || '').toLowerCase().indexOf(m[3].toLowerCase()) >= 0
      @$("#hc_list ul li ul li:Contains(#{JSON.stringify(searchText)})").show().parent().parent().show()
    else
      @$('#hc_list li').show()

  hcVisitState: (hcvCode) ->
    state = @dirtyHcVisits.get(hcvCode)?.get('state')
    state ?= @hcVisits.get(hcvCode) && 'complete'
    state ?= 'todo'
    state
