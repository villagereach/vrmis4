class Views.Users.SelectHc extends Backbone.View
  template: JST["offline/templates/users/fc_select_hc"]
  el: "#offline-container"
  vh: Helpers.View
  t: Helpers.View.t
  
  events:
    "click .hc_choice": "goToHcVisit"
    #"change #fc-health_center-search": "filterHcSelection"

  initialize: (options) ->
    @dzCode = options.dzcode
    @deliveryZone = App.deliveryZones.get(@dzCode)
    @visitMonth = options.month
    @districts = @deliveryZone.get('districts').toArray()

  goToHcVisit: (e) ->
    hcvCode = $(e.srcElement).attr('id')
    goTo('hc_visits/'+hcvCode, e) if hcvCode
  
    
  render: () ->
    @$el.html(@template(this))

    #search setup
    @origHcOptions = @$("#fc-health_center").html();
    $searchField = @$("#fc-health_center-search")
    #@filterHcSelection(null, $searchField);
    #$searchField.focus( () -> {$(this).select() }).focus();
    $('#inner_topbar').show();  

  
  filterHcSelection: (e, elem) ->
    #non-working; reroutes to login
    elem ||= e.srcElement;
    e && e.preventDefault() && e.stopPropagation()

    @searchText = @$(elem).val();
    @$("#fc-health_center").html(@origHcOptions);

    if @searchText
      searchRegex = new RegExp(@searchText, "i");
      @$("#fc-health_center option").each  () ->
        match = $(this).text().search(searchRegex)
        if match < 0
          $(this).remove()

      @$("#fc-health_center optgroup").each () ->  $(this).remove() if $(this).children().length == 0
    
  close: () =>
    this.undelegateEvents();
    this.unbind();

