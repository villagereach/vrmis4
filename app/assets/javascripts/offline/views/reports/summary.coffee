class Views.Reports.Summary extends Backbone.View
  template:  JST["offline/templates/reports/show_summary"],
  el: "#offline-container",

  initialize: (options) ->
    @products = options.products
    @healthCenters = options.healthCenters.toJSON()
    @hcVisits = options.hcVisits.toJSON()
    @scoping = options.scoping
    @visitMonths = options.visitMonths
    @stockCards = options.stockCards.toJSON()
    @packages = options.packages
    @geo_config = Helpers.Reports.structure_config()
    @geoScope = Helpers.Reports.set_geoscope(@scoping, @geo_config)
    @visitMonths = App.months
    @month = options.month
    @vh = Helpers.View
    @t = Helpers.View.t
    @reports = Helpers.Reports
    
  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    "change #deliveryZone":  "goToDeliveryZone"
    "change #district":     "goToDistrict"
    "change #healthCenter":  "goToHealthCenter"
    "change #month":  "goToMonth"

  goToDeliveryZone: (e) -> @goToScoping([@month, $(e.target).val()])
  goToDistrict: (e) -> @goToScoping([@month, @deliveryZone.code, $(e.target).val()])
  goToHealthCenter: (e) -> @goToScoping([@month, @deliveryZone.code, @district.code, $(e.target).val()])
  goToMonth: (e) -> @goToScoping(_.union([$(e.target).val()],@geoScope))

  goToScoping: (scope) -> @trigger('navigate', 'reports/summary/'+scope.join("/")+"/", true)



  render: ->
    @delegateEvents()
    scoped_hcs = @reports.geoscope_filter(@healthCenters, @geoScope, 'hc')
    scoped_hcvs = _.filter(@reports.geoscope_filter(@hcVisits, @geoScope, 'hcvisit'), (hcv) => hcv.month == @month)
    scoped_visited_hcvs = _.filter(scoped_hcvs, (hcv) ->  hcv.visited )

    #temp hack to match codes & hcv data
    @stockCards = @stockCards.map (c) ->
      c.code = c.code.replace('_','')
      c



    #convert to json, memoizing packages and tally codes
    # hack for not having Product class function
    products_array = @products.toArray()
    all_tally_codes =  products_array[0].all_tally_codes()
    products_with_packages_and_tallies = _.map products_array, (prod) ->
      p = prod.toJSON()
      p.packages = prod.packages().toJSON()
      p.tally_codes = all_tally_codes[p.code] || []
      p


    @$el.html @template
      products: products_with_packages_and_tallies
      hcs:  scoped_hcs
      all_hcvs: scoped_hcvs
      visited_hcvs: scoped_visited_hcvs
      visitMonths: @visitMonths
      month: @month
      geoScope:  @geoScope
      translatedGeoScope: @reports.translateGeoScope(@geoScope)
      deliveryZone: @deliveryZone
      district: @district
      healthCenter: @healthCenter
      target_pcts: Helpers.Targets.target_pcts

      stockCards: @stockCards
      vh: @vh
      t: @t
      reports: @reports
      geo_config: @geo_config


  close: ->
    @undelegateEvents()
    @unbind()





      
    
      
        
        
      
      
