Vrmis.Views.HcVisits ||= {}

class Vrmis.Views.HcVisits.ShowView extends Backbone.View
  template: JST["backbone/templates/hc_visits/show"]

  render: ->
    $(@el).html(@template(@model.toJSON() ))
    return this
