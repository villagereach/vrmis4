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
    @geoScope = @set_geoscope(@scoping, @geo_config)
    @visitMonths = App.hcVisitMonths
    @month = options.month
  events: 
    "change #deliveryZone":  "goToDeliveryZone"
    "change #district":     "goToDistrict"
    "change #healthCenter":  "goToHealthCenter"
    "change #month":  "goToMonth"

  goToDeliveryZone: (e) -> @goToScoping([@month, $(e.srcElement).val()])
  goToDistrict: (e) -> @goToScoping([@month, @deliveryZone.code, $(e.srcElement).val()])
  goToHealthCenter: (e) -> @goToScoping([@month, @deliveryZone.code, @district.code, $(e.srcElement).val()])
  goToMonth: (e) -> @goToScoping(_.union([$(e.srcElement).val()],@geoScope))
  
  goToScoping: (scope) -> goTo('reports/generic/'+scope.join("/")+"/")
    
    


  render: ->
    @delegateEvents()
    scoped_hcs = @geoscope_filter(@healthCenters, @geoScope, 'hc')
    scoped_hcvs = _.filter(@geoscope_filter(@hcVisits, @geoScope, 'hcvisit'), (hcv) => hcv.month == @month)
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
      deliveryZone: @deliveryZone
      district: @district
      healthCenter: @healthCenter

      stockCards: @stockCards
      vh: Helpers.View
      t: Helpers.View.t
      reports: @reports
      geo_config: @geo_config
  close: ->
    @undelegateEvents()
    @unbind()

  geoscope_filter: (source_objs, geoScope, obj_type) ->
    geoScope = _.compact(geoScope)
    return source_objs if geoScope.length == 0
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

  set_geoscope: (scoping, geo_config) =>
    geoscope = _.compact(scoping.split("/"))
    @deliveryZone = geo_config.deliveryZones[geoscope[0]]
    geoscope[0] = @deliveryZone?.code
    @district = @deliveryZone?.districts[geoscope[1]]
    geoscope[1] = @district?.code
    @healthCenter = @district?.healthCenters[geoscope[2]]
    geoscope[2] = @healthCenter?.code
    _.compact(geoscope)
    
    
    

      
  reports:
    wastage: (hcvs, products) ->
      #hcvs should be all, not just visited_hcvs (EPI data can be collected w/o visit)
      vaccine_codes = _.pluck(_.filter(products, (p) -> p.product_type == "vaccine"), 'code')
      wastages = {}
      for vcode in vaccine_codes
        wastages[vcode] = {consumed: 0, distributed: 0, measured: 0}         #assign 0s in case of no hcvs
        for hcv in hcvs
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
      for product in products
        unit_counts[product.code] ||= {used:0, delivered: 0}
        for hcv in hcvs
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
      for product in products
        stockouts[product.code] ||= 0
        for hcv in hcvs
          #window.console.log "stockouts: invs #{hcv.code} epi #{JSON.stringify(hcv.epi_inventory)} rdt #{JSON.stringify(hcv.rdt_inventory)}"
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
      
      for question in questions
        usage[question] ?= {}
        for code in codes
          usage[question][code] ?= answered: 0, yes: 0
          for hcv in hcvs
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

          
   
         
     
  