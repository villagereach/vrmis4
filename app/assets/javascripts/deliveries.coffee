jQuery ->
  $("#fc-zone-show").hide()

  $("#fc-zone-select button").click ->
    $("#fc-actions-overview").removeAttr("disabled")
    $("#fc-zone-show").show()
    $("#fc-zone-select").hide()

  $("#fc-zone-show button").click ->
    $("#fc-actions-overview").attr("disabled", "disabled")
    $("#fc-zone-select").show()
    $("#fc-zone-show").hide()

  $("[data-i18n]").each ->
    data = $(this).data()
    value = i18n_dict[data["i18n"]]
    $(this).html(value.replace(/{{([^}]+)}}/g, (str,m1)->data[m1]||str)) if value
