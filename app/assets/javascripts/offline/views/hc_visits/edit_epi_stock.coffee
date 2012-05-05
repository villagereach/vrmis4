class Views.HcVisits.EditEpiStock extends Views.HcVisits.EditScreen
  template: JST['offline/templates/hc_visits/edit_epi_stock']

  className: 'edit-epi-stock-screen'
  tabName: 'epi-stock'

  events: _.extend(_.clone(Views.HcVisits.EditScreen::events), {
    'change .calculate' : 'recalculate'
  })

  initialize: (options) ->
    super(options)

    vaccineProds = options.products.filter (p) -> p.get('product_type') is 'vaccine'
    @products = new Collections.Products(vaccineProds)

  render: ->
    super()
    @recalculate()
    @

  recalculate: ->
    that = @
    @$('.calculated').each ->
      baseId = '#' + $(@).attr('id').replace(/total$/, '')
      values = [that.$("#{baseId}first_of_month").val(), that.$("#{baseId}received").val()]
      $(@).html values.reduce(((m,n) => m + (parseInt(n)||0)), 0)
    @
