class Views.Reports.Generic extends Backbone.View
  template:  JST["offline/templates/reports/show_generic"],
  el: "#offline-container",

  initialize: (options) ->
    @products = options.products
    @healthCenters = options.healthCenters.toJSON()
    @hcVisits = options.hcVisits.toJSON()
    @scoping = options.scoping
    @visitMonths = options.visitMonths
    @stockCards = options.stockCards.toJSON()
    @packages = options.packages


  render: ->
    @delegateEvents()

    scopes = (@scoping || "").split("/")
    #month = scopes.shift()
    geoScope = scopes
    scoped_hcs = @geoscope_filter(@healthCenters, geoScope, 'hc')
    scoped_hcvs = @geoscope_filter(@hcVisits, geoScope, 'hcvisit')
    scoped_visited_hcvs = _.filter(scoped_hcvs, (hcv) ->  hcv.visited )
    scoped_hcvs_by_month = _.groupBy(scoped_hcvs, 'month')
    scoped_visited_hcvs_by_month = _.groupBy(scoped_visited_hcvs, 'month')

    #temp hack to match codes & hcv data
    @stockCards = @stockCards.map (c) -> 
      c.code = c.code.replace('_','')
      c
    
    packages_by_product = _.groupBy(@packages.toJSON(), 'product_code')
    @$el.html @template
      products: @products.toJSON()
      packages_by_product: packages_by_product
      scoped_hcvs: scoped_hcvs
      scoped_visited_hcvs: scoped_visited_hcvs
      scoped_hcvs_by_month: scoped_hcvs_by_month
      scoped_visited_hcvs_by_month: scoped_visited_hcvs_by_month
      scoped_hcs:  scoped_hcs
      visitMonths: @visitMonths
      geoScope:  geoScope
      to_pct: @to_pct
      reports: @reports
      stockCards: @stockCards

  close: ->
    @undelegateEvents()
    @unbind()

  geoscope_filter: (source_objs, geoScope, obj_type) ->
    geoScope = _.compact(geoScope)
    #todo: check geoScope for only trailing nulls/undefs
    #note: hcVisits use health_center_code, hcs just 'code', thus obj_type
    hc_code_name = obj_type.toLowerCase().match("visit") ? 'health_center_code' : 'code'
    geoCodes = ['delivery_zone_code','district_code',hc_code_name].slice(0,geoScope.length)
    f = _.filter source_objs, (obj) ->
      _.isEqual(geoScope, _.map(geoCodes, (c)->obj[c]))
    window.console.log "geofilter: source #{source_objs.length} gs #{geoScope.join("/")} type #{obj_type} gc #{geoCodes.join("/")} end #{f.length}"
    f

  to_pct: (num, denom, with_components=false) =>   #view helper
    pct = if @isNumber(num) && @isNumber(denom) && denom!=0  then Math.round(100.0 * num / denom)+"%" else "X"
    components = if with_components then " (#{num}/#{denom})"  else ""    
    pct + components
  
  isNumber: (n) -> 
    !isNaN(parseFloat(n)) && isFinite(n);

  reports:
    stockouts: (hcvs, packages_by_product, products) ->
      stockouts = {}
      for hcv in hcvs
        for product in products
          stockouts[product.code] ||= 0
          inventory = if product.product_type == 'test' then hcv.rdt_inventory else hcv.epi_inventory
          continue unless inventory?
          product_total =  _.reduce packages_by_product[product.code], (total, pack) ->
            if inventory[pack.code]? && inventory[pack.code].existing != "NR"
              (total || 0) + inventory[pack.code].existing
            else 
              total
          , null
          window.console.log "stockouts #{hcv.code} #{product.code} pt #{product_total}"
          stockouts[product] += 1 if product_total == 0    #could be null
      stockouts
      
    stock_card_usage: (hcvs, stock_cards) -> 
      questions = ['present','used_correctly']
      codes = _.pluck stock_cards, 'code'
      usage = {}
      window.console.log "scodes #{codes.toString()}"
      
      for hcv in hcvs
        for question in questions
          usage[question] ?= {}
          for code in codes
            usage[question][code] ?= answered: 0, yes: 0
            if hcv.stock_cards
              answer = hcv.stock_cards[code][question]
              if answer? && answer != "NR"
                usage[question][code]['answered'] += 1
                usage[question][code]['yes'] += 1  if answer == "yes"
      window.console.log "us"+JSON.stringify(usage)
      usage     
      
    fridge_data: (hcvs) ->
      fdata = working:0, reported:0
      for hcv in hcvs
        if hcv.refrigerators
          for fridge in hcv.refrigerators 
            if fridge.running? && fridge.running != 'unknown'
              fdata.reported += 1
              fdata.working +=1 if fridge.running == 'yes'
              
       fdata

          
   
         
     
  