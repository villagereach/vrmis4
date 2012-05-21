class Views.Reports.Refrigerators extends Backbone.View
  template:  JST["offline/templates/reports/show_refrigerators"],
  el: "#offline-container",

  initialize: (options) ->
    @healthCenters = options.healthCenters.toJSON()
    @hcVisits = options.hcVisits.toJSON()
    @scoping = options.scoping
    @visitMonths = options.visitMonths
    @packages = options.packages
    @geo_config = Helpers.Reports.structure_config()
    @geoScope = @set_geoscope(@scoping, @geo_config)
    @visitMonths = App.months
    @month = options.month
    @vh = Helpers.View
    @t = Helpers.View.t
    @reports = Helpers.Reports
    
  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click #main-link': -> @trigger('navigate', 'main', true)
    "change #deliveryZone":  "goToDeliveryZone"
    "change #district":     "goToDistrict"
    "change #healthCenter":  "goToHealthCenter"
    "change #month":  "goToMonth"

  goToDeliveryZone: (e) -> @goToScoping([@month, $(e.target).val()])
  goToDistrict: (e) -> @goToScoping([@month, @deliveryZone.code, $(e.target).val()])
  goToHealthCenter: (e) -> @goToScoping([@month, @deliveryZone.code, @district.code, $(e.target).val()])
  goToMonth: (e) -> @goToScoping(_.union([$(e.target).val()],@geoScope))

  goToScoping: (scope) -> @trigger('navigate', 'reports/refrigerators/'+scope.join("/")+"/", true)

  fridgeSort: (fridges) ->
    _.sortBy fridges, (f) -> [f.district_code, f.health_center_code, f.code].join(":")
  
  translatedFridgeProblems: (f) ->
    if !f.running?
      ""
    else
      if f.running == "no"
        if !_.isEmpty(f.running_problems) || !_.isEmpty(f.other_running_problems)
          trans_probs = _.map(_.compact(f.running_problems), (p) -> Helpers.View.t('offline.hcv.refrigerators.running_problems.'+p.toLowerCase()))
          trans_probs.push f.other_running_problems
          _.compact(trans_probs).join(",")
        else
          Helpers.View.t('reports.refrigerators.unspecified')
      else if _.isNumber(f.temperature) && (f.temperature > 8  || f.temperature < 2)
        #uncoded in form:  if they don't say 'problem' but still list a bad temp, flagged as problem
          Helpers.View.t('reports.refrigerators.problem_type.unspecified')
      else if f.running == "yes"
        "--"
      else if f.running == "unknown"
        "-"
      else 
        #should not happen?
        "?"
        

  render: ->
    @delegateEvents()
    scoped_hcs = @reports.geoscope_filter(@healthCenters, @geoScope, 'hc')
    scoped_hcvs = _.filter(@reports.geoscope_filter(@hcVisits, @geoScope, 'hcvisit'), (hcv) => hcv.month == @month)
    scoped_visited_hcvs = _.filter(scoped_hcvs, (hcv) ->  hcv.visited )
    @$el.html @template
      hcs:  scoped_hcs
      all_hcvs: scoped_hcvs
      visited_hcvs: scoped_visited_hcvs
      visitMonths: @visitMonths
      month: @month
      geoScope:  @geoScope
      translatedGeoScope: @translateGeoScope(@geoScope)
      deliveryZone: @deliveryZone
      district: @district
      healthCenter: @healthCenter
      vh: @vh
      t: @t
      reports: @reports
      geo_config: @geo_config
      fridgeSort: @fridgeSort
      translatedFridgeProblems: @translatedFridgeProblems
      fridge_data: @reports.fridge_problems(scoped_visited_hcvs)


  close: ->
    @undelegateEvents()
    @unbind()
        
  set_geoscope: (scoping, geo_config) =>
    geoscope = _.compact(scoping.split("/"))
    @deliveryZone = geo_config.deliveryZones[geoscope[0]]
    geoscope[0] = @deliveryZone?.code
    @district = @deliveryZone?.districts[geoscope[1]]
    geoscope[1] = @district?.code
    @healthCenter = @district?.healthCenters[geoscope[2]]
    geoscope[2] = @healthCenter?.code
    _.compact(geoscope)

  translateGeoScope:  (geoScope) =>
    models = ['DeliveryZone','District','HealthCenter']
    prov = [@t(['Province',App.province])]
    trans = _.map geoScope, (code,idx) => @t([models[idx],code])
    _.union prov, trans
