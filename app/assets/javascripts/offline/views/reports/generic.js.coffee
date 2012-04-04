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
    @geo_config = @structure_config()
  events: 
    "change #deliveryZone":  "goToDeliveryZone"
    "change #district":     "goToDistrict"
    "change #healthCenter":  "goToHealthCenter"

  goToDeliveryZone: (e) -> @goToScoping([$(e.srcElement).val()])
  goToDistrict: (e) -> @goToScoping([@deliveryZone.code, $(e.srcElement).val()])
  goToHealthCenter: (e) -> @goToScoping([@deliveryZone.code, @district.code, $(e.srcElement).val()])
    
  
  goToScoping: (geoScope) -> goTo('reports/generic/'+geoScope.join("/"))
    
    


  render: ->
    @delegateEvents()
    #month = scopes.shift()
    geoScope = @set_geoscope(@scoping, @geo_config)
    scoped_hcs = @geoscope_filter(@healthCenters, geoScope, 'hc')
    scoped_hcvs = @geoscope_filter(@hcVisits, geoScope, 'hcvisit')
    scoped_visited_hcvs = _.filter(scoped_hcvs, (hcv) ->  hcv.visited )
    scoped_hcvs_by_month = _.groupBy(scoped_hcvs, 'month')
    scoped_visited_hcvs_by_month = _.groupBy(scoped_visited_hcvs, 'month')

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
      scoped_hcvs_by_month: scoped_hcvs_by_month
      scoped_visited_hcvs_by_month: scoped_visited_hcvs_by_month
      scoped_hcs:  scoped_hcs
      visitMonths: @visitMonths
      geoScope:  geoScope
      vh: @view_helpers
      reports: @reports
      stockCards: @stockCards
      deliveryZone: App.deliveryZones.first()
      geo_config: @geo_config
      deliveryZone: @deliveryZone
      district: @district
      healthCenter: @healthCenter
  close: ->
    @undelegateEvents()
    @unbind()

  geoscope_filter: (source_objs, geoScope, obj_type) ->
    geoScope = _.compact(geoScope)
    #todo: check geoScope for only trailing nulls/undefs
    #note: hcVisits use health_center_code, hcs just 'code', thus obj_type
    hc_code_name = if obj_type.toLowerCase().match("visit") then 'health_center_code' else 'code'
    geoCodes = ['delivery_zone_code','district_code',hc_code_name].slice(0,geoScope.length)
    f = _.filter source_objs, (obj) ->
      _.isEqual(geoScope, _.map(geoCodes, (c)->obj[c]))
    window.console.log "geofilter: source #{source_objs.length} gs #{geoScope.join("/")} type #{obj_type} gc #{geoCodes.join("/")} end #{f.length}"
    f

  structure_config: () ->
    #JSON conversion
    config = {deliveryZones: {}}
    for dz in App.deliveryZones.toArray()
      dzcode = dz.get('code')
      config.deliveryZones[dzcode] = dz.toJSON()
      config.deliveryZones[dzcode].districts = {}
      for dist in dz.districts().toArray()
        distcode = dist.get('code')
        config.deliveryZones[dzcode].districts[distcode] = dist.toJSON()
        config.deliveryZones[dzcode].districts[distcode].healthCenters = {}
        for hc in dist.healthCenters().toArray()
          config.deliveryZones[dzcode].districts[distcode].healthCenters[hc.get('code')] = hc.toJSON()
    config

  set_geoscope: (scopes, geo_config) ->
    geoscope = _.compact(scopes.split("/"))
    @deliveryZone = geo_config.deliveryZones[geoscope[0]]
    geoscope[0] = @deliveryZone?.code
    @district = @deliveryZone?.districts[geoscope[1]]
    geoscope[1] = @district?.code
    @healthCenter = @district?.healthCenters[geoscope[2]]
    geoscope
    
    
    

  view_helpers:
    to_pct: (num, denom, with_components=false) ->  #view helper
      pct = if _.isNumber(num) && _.isNumber(denom) && denom!=0  then Math.round(100.0 * num / denom)+"%" else "X"
      components = if with_components then " (#{num}/#{denom})"  else ""    
      pct + components
      
  reports:
    wastage: (hcvs, products) ->
      #hcvs should be all, not just visited_hcvs (EPI data can be collected w/o visit)
      vaccine_codes = _.pluck(_.filter(products, (p) -> p.product_type == "vaccine"), 'code')
      wastages = {}
      for hcv in hcvs
        for vcode in vaccine_codes
          wastages[vcode] ||= {consumed: 0, distributed: 0, measured: 0}
          epi_stock = hcv.epi_stock[vcode]
          continue unless epi_stock?
          required_values = [epi_stock.first_of_month, epi_stock.received, epi_stock.distributed, epi_stock.end_of_month]
          unless _.include(required_values, "NR")
            wastages[vcode].measured += 1
            wastages[vcode].consumed += epi_stock.first_of_month + epi_stock.received - epi_stock.distributed
            wastages[vcode].distributed += epi_stock.distributed
      wastages
        
    supplies: (hcvs, products) ->
      unit_counts = {}
      for hcv in hcvs
        for product in products
          unit_counts[product.code] ||= {used:0, delivered: 0}
          inventory = if product.product_type == 'test' then hcv.rdt_inventory else hcv.epi_inventory
          for package in product.packages
             #TODO:  fix naming.  RDTs are labeled 'distributed' instead of 'delivered'
             delivered = inventory[package.code].delivered 
             delivered = inventory[package.code].distributed if _.isUndefined(delivered)
             if _.isNumber(delivered)
#               if product.product_type == "test"
#                 window.console.log "supplies: test del #{delivered} total #{unit_counts[product.code].delivered}inv #{JSON.stringify(inventory)}"
               unit_counts[product.code].delivered += (delivered * package.quantity)
             else
               #changing  products/packages can mean nil entries, even while NR is disallowed
               window.console.log "supplies: nil deliv #{hcv.code} #{package.code} inv #{JSON.stringify(inventory)}"
          for tally_code in product.tally_codes
            tally_value = deepGet(hcv, tally_code)
            if tally_value && tally_value != "NR"
              unit_counts[product.code].used += tally_value
      #special case for safetybox, which has no direct tally_codes
      unit_counts.safetybox.used = 0 
      for syringe in _.filter(products, (p) -> p.product_type=='syringe')
        unit_counts.safetybox.used += unit_counts[syringe.code].used
      unit_counts.safetybox.used = Math.round( unit_counts.safetybox.used / 150)
      unit_counts
          
        
    stockout: (hcvs, products) ->
      stockouts = {}
      for hcv in hcvs
        #window.console.log "stockouts: invs #{hcv.code} epi #{JSON.stringify(hcv.epi_inventory)} rdt #{JSON.stringify(hcv.rdt_inventory)}"
        for product in products
          stockouts[product.code] ||= 0
          inventory = if product.product_type == 'test' then hcv.rdt_inventory else hcv.epi_inventory
          continue unless inventory?
          product_total =  _.reduce product.packages, (total, pack) ->
            if inventory[pack.code]? && inventory[pack.code].existing != "NR"
              (total || 0) + inventory[pack.code].existing
            else 
              total
          , null
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
      
    fridge_problem: (hcvs) ->
      fdata = working:0, reported:0, count: 0
      for hcv in hcvs
        if hcv.refrigerators
          for fridge in hcv.refrigerators 
            fdata.count += 1
            if fridge.running? && fridge.running != 'unknown'
              fdata.reported += 1
              fdata.working +=1 if fridge.running == 'yes'
              
       fdata

          
   
         
     
  