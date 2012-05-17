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
    'click a.openable': -> 'toggleChildren'
    'click a, button': -> false # swallow
    'click #main-link': -> @trigger('navigate', 'main', true)
    
  toggleChildren:  (e) ->  
    window.console.log 'tc '+e.target.id()
    $('.child-'+e.target.id()).toggle()
    

  render: ->
    @delegateEvents()
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


    @$el.html @template_count
      products: products_with_packages_and_tallies
      all_hcs:  @healthCenters
      all_hcvs: @hcVisits
      visitMonths: @visitMonths
      stockCards: @stockCards
      vh: @vh
      t: @t
      reports: @reports
      geo_config: @geo_config


  close: ->
    @undelegateEvents()
    @unbind()
