Vrmis.Views.HcVisits ||= {}

class Vrmis.Views.HcVisits.EditView extends Backbone.View
  template : JST["backbone/templates/hc_visits/edit"]

  events :
    "submit #edit-hc_visit" : "update"

  update : (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.save(null,
      success : (hc_visit) =>
        @model = hc_visit
        window.location.hash = "/#{@model.id}"
    )

  render : ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
