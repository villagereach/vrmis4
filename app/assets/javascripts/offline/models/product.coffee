class Models.Product extends Backbone.Model
  database: provinceDb
  storeName: "products"
  idAttribute: 'code'

  get:  (attr) ->
    if (typeof this[attr] == 'function')  then  this[attr]() else Backbone.Model.prototype.get.call(this, attr)

  packages: ->
    code = @get('code')
    packages = @collection.snapshot.packages().filter (pkg) ->
      pkg.get('product_code') == code
    new Collections.Packages(packages)

  @allProductTypes: ->
    ['fuel', 'safety', 'syringe', 'test', 'vaccine']

  all_tally_codes: ->
    #hack:  should be class method and memoized. how to?

    #note all vacc except polio (oral?) use 1-2 syringes  (?2? -- see doc)
    #child
    regimens_syringes =
      penta: [["1","2","3"], ["syringe05ml"]]
      polio: [["0","1","2","3"], []]
      bcg:   [[""], ["syringe005ml","syringe5ml"]]
      measles: [[""], ["syringe05ml", "syringe5ml"]]

    ages_locs = ["hc0_11","hc12_23","mb0_11","mb12_23"]

    all_codes = {}

    for vaccine, reg_syr of regimens_syringes
      regimen_steps = reg_syr[0]
      syringes = reg_syr[1]
      all_codes[vaccine] = []
      for regimen_step in regimen_steps
        for age_loc in ages_locs
          tally_code = ["child_vac_tally",vaccine+regimen_step,age_loc]
          all_codes[vaccine].push tally_code
          for syringe in syringes
            all_codes[syringe] ||= []
            all_codes[syringe].push tally_code

    #adult
    mobile_only_categories = ["w_pregnant","w_15_49_community","other"]
    both_loc_categories = ["w_15_49_student","w_15_49_labor","student","labor"]

    product_codes = ["tetanus","syringe05ml"]
    for cat in both_loc_categories
      for product_code in product_codes
        all_codes[product_code] ||= []
        all_codes[product_code].push ["adult_vac_tally",cat,"tet1hc"]
        all_codes[product_code].push ["adult_vac_tally",cat,"tet2_5hc"]
    for cat in _.union(mobile_only_categories, both_loc_categories)
      for product_code in product_codes
        all_codes[product_code].push ["adult_vac_tally",cat,"tet1mb"]
        all_codes[product_code].push ["adult_vac_tally",cat,"tet2_5mb"]

    #rdts
    for rdt_code in ["hivdetermine","hivunigold","syphilis","malaria"]
      all_codes[rdt_code] = [["rdt_stock",rdt_code, "total"]]

    return all_codes


  tally_codes: ->
    @all_tally_codes[@get('code')] || []
