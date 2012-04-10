class Views.Users.SelectHc extends Backbone.View
  template: JST["offline/templates/users/fc_select_hc"]
  el: "#offline-container"
  vh: Helpers.View
  t: Helpers.View.t

  events:
    "submit form": "swallowEvent"
    "click .hc_choice": "goToHcVisit"
    "change #fc-health_center-search": "filterHcSelection"

  initialize: (options) ->
    @dzCode = options.dzcode
    @deliveryZone = App.deliveryZones.get(@dzCode)
    @visitMonth = options.month
    @districts = @deliveryZone.get('districts').toArray()

  goToHcVisit: (e) ->
    hcvCode = $(e.target).attr('id')
    goTo('hc_visits/'+hcvCode, e) if hcvCode


  render: () ->
    @$el.html(@template(this))
    $("#fc-health_center-search").focus(-> $(this).select()).focus()
    $('#inner_topbar').show()


  filterHcSelection: (e, elem) ->
    #non-working; reroutes to login
    elem ||= e.target
    e && e.preventDefault() && e.stopPropagation()

    if @searchText = @$(elem).val()
      this.$('ul, li').hide()
      jQuery.expr[":"].Contains = (a, i, m) ->
        (a.textContent || a.innerText || "").toLowerCase().indexOf(m[3].toLowerCase())>=0
      this.$("li:Contains(#{@searchText})").show().parent().show()
    else
      this.$('ul, li').show()

  close: () =>
    this.undelegateEvents()
    this.unbind()

  swallowEvent: (e) ->
    e.preventDefault()
    e.stopPropagation()

