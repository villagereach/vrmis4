class window.OfflineRouter extends Backbone.Router
  routes:
    ''                                     : 'root'
    'login'                                : 'userLoginForm'
    'home'                                 : 'mainUserPage'
    'select_hc/:month/:dzcode'             : 'selectHcPage'
    'warehouse_visits/:month/:dzcode/ideal': 'idealWarehousePage'
    'warehouse_visits/:month/:dzcode'      : 'editWarehousePage'
    'hc_visits/:code'                      : 'hcVisitPage'
    'hc_visits/:code/edit'                 : 'editHcVisitPage'
    'hc_visits/:code/:tab'                 : 'hcVisitPage'
    'reports/adhoc'                        : 'adhocReportsPage'
    'reports/summary/:month/*scoping'      : 'summaryReportPage'
    'sync'                                 : 'syncPage'
    'reset'                                : 'resetDatabase'
    '*url'                                 : 'err404'

  initialize: (@app) ->

  root: ->
    @navigate 'home', trigger: true

  userLoginForm: ->
    @loginView = new Views.Users.LoginView
      collection: @app.users

    @loginView.on 'login', (user) =>
      @currentUser = user
      @navigate 'home', trigger: true

    @display => @loginView

  mainUserPage: ->
    # if not synced w/ server then redirect to sync page
    if @app.deliveryZones.length == 0
      @navigate 'sync', trigger: true
      return

    @mainView ?= new Views.Users.Main
      deliveryZones: @app.deliveryZones
      months: @app.hcVisitMonths
    @display => @mainView

  selectHcPage: (month, dzCode) ->
    @display => new Views.Users.SelectHc
      month: month
      deliveryZone: @app.deliveryZones.get(dzCode)
      hcVisits: @app.hcVisits
      dirtyHcVisits: @app.dirtyHcVisits

  idealWarehousePage: (month, dzCode) ->
    @display => new Views.WarehouseVisits.Ideal
      month: month
      deliveryZone: @app.deliveryZones.get(dzCode)
      products: @app.products
      packages: @app.packages

  editWarehousePage: (month, dzCode) ->
    warehouseVisit = new Models.WarehouseVisit
      code: "#{dzCode}-#{month}"

    @display => new Views.WarehouseVisits.Edit
      warehouseVisit: warehouseVisit
      deliveryZone: @app.deliveryZones.get(dzCode)
      products: @app.products
      packages: @app.packages

  editHcVisitPage: (visitCode, tabName) ->
    if hcVisit = @app.dirtyHcVisits.get(visitCode)
      @hcVisitPage(visitCode, tabName, hcVisit)
    else if hcVisit = @app.hcVisits.get(visitCode)
      $.getJSON("#{App.baseUrl}/users/current")
        .success (user) =>
          hcVisit = @app.dirtyHcVisits.create(hcVisit.toJSON()) if user?.role == 'admin'
        .complete =>
          @hcVisitPage visitCode, tabName, hcVisit
    else
      @hcVisitPage(visitCode, tabName)

  hcVisitPage: (visitCode, tabName, hcVisit) ->
    hcVisit ?= @app.dirtyHcVisits.get(visitCode)
    hcVisit ?= @app.hcVisits.get(visitCode)
    unless hcVisit
      hcVisit = new Models.DirtyHcVisit(code: visitCode)
      healthCenter = @app.healthCenters.get(hcVisit.get('health_center_code'))
      hcVisit.set 'delivery_zone_code', healthCenter.get('delivery_zone_code')
      hcVisit.set 'district_code', healthCenter.get('district_code')
      @app.dirtyHcVisits.add(hcVisit)

    hcVisitView = new Views.HcVisits[if hcVisit.isEditable() then 'Edit' else 'Show']
      hcVisit: hcVisit
      healthCenter: @app.healthCenters.get(hcVisit.get('health_center_code'))
      packages: @app.packages
      products: @app.products
      stockCards: @app.stockCards
      equipmentTypes: @app.equipmentTypes

    hcVisitView.selectTab(tabName) if tabName
    @display => hcVisitView

  adhocReportsPage: ->
    @display => new Views.Reports.Adhoc
      months: @app.hcVisitMonths

  summaryReportPage: (month, scoping) ->
    @display => new Views.Reports.Summary
      products: @app.products
      healthCenters: @app.healthCenters
      hcVisits: @app.hcVisits
      visitMonths: @app.hcVisitMonths
      scoping: scoping
      month: month
      stockCards: @app.stockCards
      packages: @app.packages

  resetDatabase: ->
    window.location = window.location.pathname.replace /\/?$/, '/reset'

  syncPage: ->
    @display => new Views.Users.Sync
      model: @app.syncState

  err404: (url) ->
    window.alert("unknown url #{url}")

  display: (func) ->
    @currentView.close() if @currentView

    that = @
    @currentView = func() # func() should return a view
    @currentView.on 'navigate', => that.navigate(arguments...)
    @currentView.render()
