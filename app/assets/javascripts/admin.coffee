#= require jquery_ujs
#= require jquery-ui

jQuery ->
  $(".required .label").append("*")

  $(".change-order").click ->
    $(".reorderable").removeClass("reorderable-disabled").sortable
      axis: "y"
      dropOnEmpty: false
      handle: ".handle"
      cursor: "move"
      items: "tr"
      scroll: true
      activate: (event,ui)->
        ui.helper.removeClass("reorderable-failure")
        ui.helper.addClass("reorderable-active")
      update: ->
        $("tr:odd").removeClass("odd").addClass("even")
        $("tr:even").removeClass("even").addClass("odd")
        $.post(
          $(this).data "sort-url"
          $(this).sortable "serialize"
          ->
            $(".reorderable-active")
              .switchClass("reorderable-active", "reorderable-success", "normal")
              .removeClass("reorderable-success", "normal")
          "script"
        ).error ->
          $(".reorderable-active")
            .switchClass("reorderable-active", "reorderable-failure", "normal")

  performIsaCalcs = (options) ->
    product = options.product
    population = options.population
    calcs = options.calcs || {}
    isa = options.isa || {}

    deps = {}
    for code, calc of calcs when m = calc.match /\bisa\..+?\b(?: *=)?/g
      d = (v.slice(4) for v in m when v.match /^isa\.[^ =]+$/)
      deps[code] = d if d.length > 0

    queue = if product then [product] else (code for code, calc of calcs)

    errors = {}
    calculated = {}
    while code = queue.pop()
      continue if calculated[code]
      if deps[code]
        queue.push code, deps[code]...
        delete deps[code]
        continue

      window.console.log "calculating isa for #{code}..."
      try
        result = eval (calcs[code] || "")
        isa[code] = calculated[code] = result
      catch error
        window.console.error "Error calculating ISA for #{code}: #{error}"
        errors[code] = error

    [isa, errors]

  # must define productCode and calcs in global/window namespace
  $("#test-isa-calc").click (e) ->
    e.preventDefault()

    isaCalcs[productCode] = $("#product_isa_calc").val()
    isaCalcs[productCode] ?= $("#test-isa-calc-readonly").text()

    [isa, errors] = performIsaCalcs
      population: $("#test-isa-population").val()
      product: productCode
      calcs: isaCalcs

    if errors[productCode]
      $("#test-isa-result").val('')
      $("#test-isa-error").text(errors[productCode].toString())
    else
      $("#test-isa-error").text('')
      $("#test-isa-result").val(isa[productCode])

  $("#health_center_population").change ->
    population = $(this).val()
    return unless population

    [isa, errors] = performIsaCalcs
      population: population
      calcs: isaCalcs

    $(".hc-isa-value, .hc-isa-error").text("").removeClass('isa-different')
    $("#hc-isa-#{code}-error").text(error.toString()) for code, error of errors

    for code, value of isa
      $elem =  $("#hc-isa-#{code}")
      $field = $elem.closest(".value").children("input")
      $elem.text(value)
      $elem.addClass('isa-different') if $field.val() isnt $elem.text()

  $("#hc-fill-isas").click (e) ->
    e.preventDefault()

    $('.hc-isa-value').each ->
      $this = $(this)
      $this.closest(".value").children("input").val($this.text())

    $("#health_center_population").trigger("change")
