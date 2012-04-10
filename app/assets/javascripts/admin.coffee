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
