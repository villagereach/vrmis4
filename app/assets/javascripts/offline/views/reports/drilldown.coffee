class Views.Reports.Drilldown extends Backbone.View
  template_count:  JST["offline/templates/reports/show_drilldown_count"],
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
    @visitMonths = App.months
    @month = options.month
    @vh = Helpers.View
    @t = Helpers.View.t
    @reports = Helpers.Reports
    
  events:
    'submit': -> false # swallow
    'click a[href=#], button': -> false # swallow
    'click .opener': 'toggleChildren'
    'click #main-link': -> @trigger('navigate', 'main', true)
    
  toggleChildren:  (e) ->  
    window.console.log 'tc '+ e.target.id
    @$('#opened-by-'+e.target.id).toggle()
#    @$('#arrow-up-'+e.target.id).toggle()
#    @$('#arrow-down-'+e.target.id).toggle()

  render: ->
    @delegateEvents()
    #temp hack to match codes & hcv data
#    @stockCards = @stockCards.map (c) ->
#      c.code = c.code.replace('_','')
#      c

    #convert to json, memoizing packages and tally codes
    # hack for not having Product class function
    products_array = @products.toArray()
    all_tally_codes =  products_array[0].all_tally_codes()
    products_with_packages_and_tallies = _.map products_array, (prod) ->
      p = prod.toJSON()
      p.packages = prod.packages().toJSON()
      p.tally_codes = all_tally_codes[p.code] || []
      p

    unscoped_config = 
      products: products_with_packages_and_tallies
      visitMonths: @visitMonths
      stockCards: @stockCards
      vh: @vh
      t: @t
      geo_config: @geo_config
      reports: @reports


    @$el.html @template_count unscoped_config
    row_template = JST["offline/templates/reports/_data_completeness_row"]
    @$('#drilldown-header').html row_template({t: @t, is_header: true})
    for month in @visitMonths
      month_hcs = @healthCenters
      month_hcvs = _.filter(@hcVisits, (hcv) => hcv.month == month)
      month_css_id = '#data-row-' + @reports.css_id_from_full_scope(month, [])
      scoped_config = _.extend unscoped_config, 
        scoped_hcs: @healthCenters
        scoped_hcvs: month_hcvs
        scoped_visited_hcvs: _.filter(month_hcvs, (hcv) =>  hcv.visited)
      @$(month_css_id).html row_template scoped_config
      
      for dzcode, dz of @geo_config.deliveryZones
        dz_hcs = @reports.geoscope_filter(month_hcs, [dzcode], 'hc')
        dz_hcvs = @reports.geoscope_filter(month_hcvs, [dzcode], 'hcvisit')
        dz_css_id = '#data-row-' + @reports.css_id_from_full_scope(month, [dzcode])
        scoped_config = _.extend unscoped_config, 
          scoped_hcs: dz_hcs,
          scoped_hcvs: dz_hcvs,
          scoped_visited_hcvs: _.filter(dz_hcvs, (hcv) => hcv.visited)
        @$(dz_css_id).html row_template scoped_config
        
        for distcode, district of dz.districts
          district_hcs = @reports.geoscope_filter(dz_hcs, [dzcode, distcode], 'hc')
          district_hcvs = @reports.geoscope_filter(dz_hcvs, [dzcode, distcode], 'hcvisit')
          district_css_id = '#data-row-' + @reports.css_id_from_full_scope(month, [dzcode, distcode])
          scoped_config = _.extend unscoped_config, 
            scoped_hcs: district_hcs
            scoped_hcvs: district_hcvs
            scoped_visited_hcvs: _.filter(district_hcvs, (hcv) => hcv.visited)
          @$(district_css_id).html row_template scoped_config

          for hccode, hc of district.healthCenters
            # could be shortened of course.  parallel for eventual abstraction
            hc_hcs = @reports.geoscope_filter(district_hcs, [dzcode, distcode, hccode], 'hc')
            hc_hcvs = @reports.geoscope_filter(district_hcvs, [dzcode, distcode, hccode], 'hcvisit')
            hc_css_id = '#data-row-' + @reports.css_id_from_full_scope(month, [dzcode, distcode, hccode])
            scoped_config = _.extend unscoped_config, 
              scoped_hcs: hc_hcs
              scoped_hcvs: hc_hcvs
              scoped_visited_hcvs: _.filter(hc_hcvs, (hcv) => hcv.visited)
            @$(hc_css_id).html row_template scoped_config

  close: ->
    @undelegateEvents()
    @unbind()
