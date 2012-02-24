Vrmis.Views.HcVisits ||= {}

class Vrmis.Views.HcVisits.NewView extends Backbone.View
  template: JST["backbone/templates/hc_visits/new"]

  events:
    "submit #new-hc_visit": "save"

  constructor: (options) ->
    super(options)
    @model = new @collection.model()

    @model.bind("change:errors", () =>
      this.render()
    )

  save: (e) ->
    e.preventDefault()
    e.stopPropagation()

    @model.unset("errors")

    @collection.create(@model.toJSON(),
      success: (hc_visit) =>
        @model = hc_visit
        window.location.hash = "/#{@model.id}"

      error: (hc_visit, jqXHR) =>
        @model.set({errors: $.parseJSON(jqXHR.responseText)})
    )

  render: ->
    $(@el).html(@template(@model.toJSON() ))

    this.$("form").backboneLink(@model)

    return this
