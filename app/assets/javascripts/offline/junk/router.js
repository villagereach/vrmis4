//class OfflineApp.Routers.HcVisits extends Backbone.Router
//  routes:
//    "": "index"

//  index: ->
//    alert "Hello, world!  This is..."

//class Vrmis.Routers.HcVisitsRouter extends Backbone.Router
//  initialize: (options) ->
//    @hcVisits = new Vrmis.Collections.HcVisitsCollection()
//    @hcVisits.reset options.hcVisits

//  routes:
//    "/new"      : "newHcVisit"
//    "/index"    : "index"
//    "/:id/edit" : "edit"
//    "/:id"      : "show"
//    ".*"        : "index"

//  newHcVisit: ->
//    @view = new Vrmis.Views.HcVisits.NewView(collection: @hc_visits)
//    $("#hc_visits").html(@view.render().el)

//  index: ->
//    @view = new Vrmis.Views.HcVisits.IndexView(hc_visits: @hc_visits)
//    $("#hc_visits").html(@view.render().el)

//  show: (id) ->
//    hc_visit = @hc_visits.get(id)

//    @view = new Vrmis.Views.HcVisits.ShowView(model: hc_visit)
//    $("#hc_visits").html(@view.render().el)

//  edit: (id) ->
//    hc_visit = @hc_visits.get(id)

//    @view = new Vrmis.Views.HcVisits.EditView(model: hc_visit)
//    $("#hc_visits").html(@view.render().el)
