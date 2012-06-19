window.Helpers.Reports =
  deepGet: (obj, key) ->
    key_array = if _.isString(key) then key.split('.') else key
    _.reduce key_array, (val, key) ->
        val ?= {}
        if val.get then val.get(key) else val[key]
      , obj

  geoscope_filter: (source_objs, geoScope, obj_type) ->
    geoScope = _.compact(geoScope)
    return source_objs if geoScope.length == 0
    #todo: check geoScope for only trailing nulls/undefs
    #note: hcVisits use health_center_code, hcs just 'code', thus obj_type
    hc_code_name = if obj_type.toLowerCase().match("visit") then 'health_center_code' else 'code'
    geoCodes = ['delivery_zone_code','district_code',hc_code_name].slice(0,geoScope.length)
    f = _.filter source_objs, (obj) ->
      _.isEqual(geoScope, _.map(geoCodes, (c)->obj[c]))
    #window.console.log "geofilter: source #{source_objs.length} gs #{geoScope.join("/")} type #{obj_type} gc #{geoCodes.join("/")} end #{f.length}"
    f

  css_id_from_full_scope: (month, geoScope) ->
    full_scope = _.compact(geoScope)
    full_scope.unshift(month)
    labels = ['month','dz','district','hc'].slice(0,geoScope.length + 1)
    _.flatten(_.zip(labels, full_scope)).join("-")
    
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


  
  structure_config: () ->
    #JSON conversion
    config = {deliveryZones: {}}
    for dz in App.config.deliveryZones().toArray()
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
             unit_counts[product.code].delivered += (delivered * package.quantity)
        for tally_code in product.tally_codes
          tally_value = @deepGet(hcv, tally_code)
          if tally_value && tally_value != "NR"
            unit_counts[product.code].used += tally_value
    #special case for safetybox, which has no direct tally_codes
    unit_counts.safetybox.used = 0
    for syringe in _.filter(products, (p) -> p.product_type=='syringe')
      unit_counts.safetybox.used += unit_counts[syringe.code].used
    unit_counts.safetybox.used = Math.round( unit_counts.safetybox.used / 150)
    unit_counts


  stockouts_and_full_deliveries: (hcs, hcvs, products) ->
    # visits_by_type assembles '% of HCs with any vaccine stockout' stat
    # TODO:  expand to make more general, yielding HCs-with-any, HCs-with-multiple[-by-type]
    stockouts = {'visits_by_type': {}}
    full_deliveries = {}
    isas = {}
    for product in products
      #ensure 0s even with no hcvs
      stockouts[product.code] = 0
      stockouts.visits_by_type[product.product_type] ||= 0
      full_deliveries[product.code] = 0
      for hc in hcs
        isas[product.code] ||= {}
        isas[product.code][hc.code] = hc.ideal_stock_amounts[product.code]
    
    for hcv in hcvs
      stocked_out_types_for_hcv = []   
      for product in products
        #window.console.log "stockouts: invs #{hcv.code} epi #{JSON.stringify(hcv.epi_inventory)} rdt #{JSON.stringify(hcv.rdt_inventory)}"
        inventory = if product.product_type == 'test' then hcv.rdt_inventory else hcv.epi_inventory
        continue unless inventory?
        product_existing_total =  _.reduce product.packages, (total, pack) ->
          if inventory[pack.code]? && inventory[pack.code].existing? && inventory[pack.code].existing != "NR"
            (total || 0) + inventory[pack.code].existing * pack.quantity
          else
            total
        , null
        product_delivered_total = _.reduce product.packages, (total, pack) ->
          if inventory[pack.code]? && inventory[pack.code].delivered?  && inventory[pack.code].delivered != "NR"
            total + inventory[pack.code].delivered * pack.quantity
          else
            total
        , 0
        if product_existing_total == 0
          stockouts[product.code] += 1
          unless _.include(stocked_out_types_for_hcv, product.product_type)
            stocked_out_types_for_hcv.push product.product_type 
        if product_delivered_total + (product_existing_total || 0) >= isas[product.code][hcv.health_center_code]
          full_deliveries[product.code] += 1
      for product_type in stocked_out_types_for_hcv
        stockouts.visits_by_type[product_type]  += 1
    return {stockouts: stockouts, full_deliveries: full_deliveries}

  stock_card_usage: (hcvs, stock_cards) ->
    questions = ['present','used_correctly']
    codes = _.pluck stock_cards, 'code'
    usage = {}

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
    usage


 

  fridge_problems: (hcvs) ->
    fdata = problems: [], past_problems: [], ok: []
    for hcv in hcvs
      if hcv.refrigerators
        for fridge in hcv.refrigerators
          #add data from hcv for individual reporting
          fridge.health_center_code = hcv.health_center_code
          fridge.district_code = hcv.district_code
          if fridge.running == 'no' || (_.isNumber(fridge.temperature) && !(1 < fridge.temperature < 9))
            fdata.problems.push(fridge)
          else if fridge.past_problem == "yes"
            fdata.past_problems.push(fridge)
          else
            fdata.ok.push(fridge)
    #also return counts for convenience
    fdata.counts = 
      problems: fdata.problems.length
      past_problems: fdata.past_problems.length
      ok: fdata.ok.length
    fdata.counts.total = fdata.counts.problems + fdata.counts.past_problems + fdata.counts.ok    
    fdata

  coverage: (hcs, hcvs, target_pcts) ->
    coverages = total_pop: 0, target_pops: {}, doses_given: {}
    all_adult_codes = _.union(_.keys(target_pcts.adult), target_pcts.adult_targetless)
    #child and adult codes assumed uniq!
    child_codes = _.keys(target_pcts.child)
    all_codes = _.union(child_codes, all_adult_codes)
    
    for code in all_codes
      coverages.doses_given[code] = 0

    for hc in hcs
      for vacc_code, monthly_pct of _.extend(_.clone(target_pcts.child), target_pcts.adult)
        coverages.target_pops[vacc_code] ||= 0
        coverages.target_pops[vacc_code] += Math.floor(hc.population * monthly_pct)
        coverages.total_pop += hc.population
    for hcv in hcvs
      #child
      for vacc_code, monthly_pct of target_pcts.child
        continue if vacc_code == 'full' #separate input form for full
        #convention is only 0-11mo vaccinatiions count
        for tally in [hcv.child_vac_tally[vacc_code].hc0_11, hcv.child_vac_tally[vacc_code].mb0_11]
          if tally? && tally != "NR"
            coverages.doses_given[vacc_code] += tally
      #full child
      for gender in ['male','female']
        for location in ['hc', 'mb']
          tally = hcv.full_vac_tally[gender][location]
          if tally? && tally != "NR"
            coverages.doses_given.full += tally

      #adults
      for adult_code in all_adult_codes
        for dose_loc in ['tet1hc','tet1mb','tet2hc','tet2mb']
          #tet?hc will be undef for many; not on input form
          tally = hcv.adult_vac_tally[adult_code][dose_loc]
          if tally? && tally != "NR"
            coverages.doses_given[adult_code] += tally          
    coverages
    
  
  delivery_intervals:  (hcvs) ->
    target_interval = 33   #days
    ms_per_day = 1000*60*60*24
    
    data = count: 0, count_under_target: 0, total: 0
    for hcv in hcvs
      continue unless hcv.last_visited?   #some HCVs could be new; discard
      #assume "end of month" so last visited keeps growing over time
      current =  if hcv.visited  then Date.parse(hcv.visited_at) else Date.parse(hcv.month+"-01")+30*ms_per_day
      previous = Date.parse(hcv.last_visited)
      unless _.isNumber(previous) && _.isNumber(current)
        window.console.log("delivery:  NaN found on "+ hcv.health_center_code)
        continue
      interval = Math.round((current - previous) / ms_per_day)
      data.count += 1 if hcv.visited
      data.total += interval
      data.min = interval if !data.min? || data.min > interval
      data.max = interval if !data.max? || data.max < interval
      data.count_under_target += 1 if interval <= target_interval
    data.avg = if data.count > 0 then Math.round(data.total / data.count) else "N/A"
    data
