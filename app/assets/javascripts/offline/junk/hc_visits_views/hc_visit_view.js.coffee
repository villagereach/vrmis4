Vrmis.Views.HcVisits ||= {}

class Vrmis.Views.HcVisits.HcVisitView extends Backbone.View
  template: JST["backbone/templates/hc_visits/hc_visit"]

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
