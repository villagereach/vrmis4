jQuery ->
  $(".required .label").append("*")

  #---[ .reorderable ]---------------------------------------------------------#
  # makes data in a table orderable by dragging rows to their new position.    #
  # makes an ajax request to the server to update position information using   #
  # the path specified by data-sort-url.  model being sorted should probably   #
  # use the acts_as_list gem (class Foo ... acts_as_list ... end).             #
  #                                                                            #
  # formtastic example (using haml):                                           #
  #   %table.reorderable{ :data => { "sort-url" => sort_foo_path }}            #
  #----------------------------------------------------------------------------#
  $(".reorderable").sortable
    axis: "y"
    dropOnEmpty: false
    handle: ".handle"
    cursor: "crosshair"
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
