class Views.Reports.Links extends Backbone.View
  template:  JST["offline/templates/reports/show_links"],
  el: "#offline-container",

  initialize: (options) ->
    @month = options.month
    @scoping = options.scoping
    
  render: ->
    @delegateEvents()
    month_and_full_scoping = month_and_dzcode = @month+"/"
    if @scoping
      month_and_full_scoping += @scoping
      month_and_dzcode += @scoping.split("/")[0]

    @$el.html @template
      month: @month
      month_and_full_scoping: month_and_full_scoping
      month_and_dzcode: month_and_dzcode
      vh: Helpers.View
      t: Helpers.View.t
  close: ->
    @undelegateEvents()
    @unbind()
  