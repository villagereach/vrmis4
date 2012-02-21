Vrmis.Views.HcVisits ||= {}

class Vrmis.Views.HcVisits.IndexView extends Backbone.View
  template: JST["backbone/templates/hc_visits/index"]

  initialize: () ->
    @options.hcVisits.bind('reset', @addAll)

  addAll: () =>
    @options.hcVisits.each(@addOne)

  addOne: (hcVisit) =>
    view = new Vrmis.Views.HcVisits.HcVisitView({model : hcVisit})
    @$("tbody").append(view.render().el)

  render: =>
    $(@el).html(@template(hcVisits: @options.hcVisits.toJSON() ))
    @addAll()

    return this
