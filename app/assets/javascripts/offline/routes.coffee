class window.OfflineRouter extends Backbone.Router
  routes:
    ''                                : 'root'
    'login'                           : 'userLoginForm'
    'main'                            : 'mainPage'
    'main/:month/:dzcode'             : 'mainPage'
    'select_hc/:month/:dzcode'        : 'selectHcPage'
    'hc_visits/:code'                 : 'hcVisitPage'
    'hc_visits/:code/edit'            : 'editHcVisitPage'
    'hc_visits/:code/:tab'            : 'hcVisitPage'
    'warehouse_visits/:code'          : 'warehouseVisitPage'
    'warehouse_visits/:code/edit'     : 'editWarehouseVisitPage'
    'warehouse_visits/:code/ideal'    : 'idealWarehouseVisitPage'
    'reports/adhoc'                   : 'adhocReportsPage'
    'reports/summary/:month/*scoping' : 'summaryReportPage'
    'reports/refrigerators/:month/*scoping' : 'refrigeratorsReportPage'
    'reports/drilldown'               : 'drilldownReportPage'
    'sync'                            : 'syncPage'
    'sync/:action'                    : 'syncPage'
    'reset'                           : 'resetDatabase'
    '*url'                            : 'err404'

  initialize: (@app) ->

  root: ->
    @navigate 'login', trigger: true

  userLoginForm: ->
    @loginView = new Views.Users.Login
      collection: @app.users

    @loginView.on 'login', (user) =>
      @currentUser = user
      @navigate 'main', trigger: true

    @display => @loginView

  mainPage: (month, dzCode) ->
    # if not synced w/ server then redirect to sync page
    if @app.config.deliveryZones().length == 0
      @navigate 'sync/pull', trigger: true
      return

    deliveryZone = @app.config.deliveryZones().get(dzCode) if dzCode

    @mainView ?= new Views.Users.Main
      deliveryZones: @app.config.deliveryZones()
      deliveryZone: deliveryZone
      months: @app.months
      month: month
      screen: if dzCode then 'zone-show' else 'zone-select'
    @display => @mainView

  selectHcPage: (month, dzCode) ->
    @display => new Views.Users.SelectHc
      month: month
      deliveryZone: @app.config.deliveryZones().get(dzCode)
      hcVisits: @app.hcVisits
      dirtyHcVisits: @app.dirtyHcVisits

  editHcVisitPage: (visitCode, tabName) ->
    if hcVisit = @app.dirtyHcVisits.get(visitCode)
      @hcVisitPage(visitCode, tabName, hcVisit)
    else if hcVisit = @app.hcVisits.get(visitCode)
      $.getJSON("#{App.baseUrl}/users/current")
        .success (user) =>
          hcVisit = @app.dirtyHcVisits.create(hcVisit.toJSON()) if user?.role is 'admin'
        .complete =>
          @hcVisitPage visitCode, tabName, hcVisit
    else
      @hcVisitPage(visitCode, tabName)

  hcVisitPage: (visitCode, tabName, hcVisit) ->
    hcVisit ?= @app.dirtyHcVisits.get(visitCode)
    hcVisit ?= @app.hcVisits.get(visitCode)
    unless hcVisit
      hcVisit = new Models.DirtyHcVisit(code: visitCode)
      healthCenter = @app.config.healthCenters().get(hcVisit.get('health_center_code'))
      hcVisit.set 'delivery_zone_code', healthCenter.get('delivery_zone_code')
      hcVisit.set 'district_code', healthCenter.get('district_code')
      @app.dirtyHcVisits.add(hcVisit)

    hcVisitView = new Views.HcVisits[if hcVisit.isEditable() then 'Edit' else 'Show']
      hcVisit: hcVisit
      healthCenter: @app.config.healthCenters().get(hcVisit.get('health_center_code'))
      packages: @app.config.packages()
      products: @app.config.products()
      stockCards: @app.config.stockCards()
      equipmentTypes: @app.config.equipmentTypes()

    hcVisitView.selectTab(tabName) if tabName
    @display => hcVisitView

  idealWarehouseVisitPage: (visitCode) ->
    result = visitCode.match(/^(.+?)-(\d{4}-\d{2})$/)
    @display => new Views.WarehouseVisits.Ideal
      month: result[2]
      deliveryZone: @app.config.deliveryZones().get(result[1])
      products: @app.config.products()
      packages: @app.config.packages()

  editWarehouseVisitPage: (visitCode) ->
    if warehouseVisit = @app.dirtyWarehouseVisits.get(visitCode)
      @warehouseVisitPage visitCode, warehouseVisit
    else if warehouseVisit = @app.warehouseVisits.get(visitCode)
      $.getJSON("#{App.baseUrl}/users/current")
        .success (user) =>
          warehouseVisit = @app.dirtyWarehouseVisits.create(warehouseVisit.toJSON()) if user?.role is 'admin'
        .complete =>
          @warehouseVisitPage visitCode, warehouseVisit
    else
      @warehouseVisitPage visitCode

  warehouseVisitPage: (visitCode, warehouseVisit) ->
    warehouseVisit ?= @app.dirtyWarehouseVisits.get(visitCode)
    warehouseVisit ?= @app.warehouseVisits.get(visitCode)
    unless warehouseVisit
      warehouseVisit = new Models.DirtyWarehouseVisit(code: visitCode)
      warehouse = @app.config.warehouses().at(0) # only one warehouse per province
      warehouseVisit.set 'warehouse_code', warehouse.get('code')
      @app.dirtyWarehouseVisits.add(warehouseVisit)

    @display => new Views.WarehouseVisits[if warehouseVisit.isEditable() then 'Edit' else 'Show']
      warehouseVisit: warehouseVisit
      warehouse: @app.config.warehouses().at(0)
      deliveryZone: @app.config.deliveryZones().get(warehouseVisit.get('delivery_zone_code'))
      products: @app.config.products()
      packages: @app.config.packages()

  adhocReportsPage: ->
    @display => new Views.Reports.Adhoc
      months: @app.months

  summaryReportPage: (month, scoping) ->
    @display => new Views.Reports.Summary
      products: @app.config.products()
      healthCenters: @app.config.healthCenters()
      hcVisits: @app.hcVisits
      visitMonths: @app.months
      scoping: scoping
      month: month
      stockCards: @app.config.stockCards()
      packages: @app.config.packages()

  refrigeratorsReportPage: (month, scoping) ->
    @display => new Views.Reports.Refrigerators
      healthCenters: @app.healthCenters
      hcVisits: @app.hcVisits
      visitMonths: @app.months
      scoping: scoping
      month: month


  drilldownReportPage: ->
    @display => new Views.Reports.Drilldown
      products: @app.config.products()
      healthCenters: @app.config.healthCenters()
      hcVisits: @app.hcVisits
      visitMonths: @app.months
      stockCards: @app.config.stockCards()
      packages: @app.config.packages()
    

  resetDatabase: ->
    window.location = window.location.pathname.replace /\/?$/, '/reset'

  syncPage: (action) ->
    syncView = new Views.Sync.Overview
      syncState: @app.syncState
      dirtyHcVisits: @app.dirtyHcVisits
      dirtyWarehouseVisits: @app.dirtyWarehouseVisits

    @display => syncView

    syncView.pushVisitsDialog() if action is 'push'
    syncView.progressDialog(['checkUpdates', 'pullData']) if action is 'update'
    syncView.progressDialog(['pullData']) if action is 'pull'

  err404: (url) ->
    window.alert("unknown url #{url}")

  display: (func) ->
    @currentView.close() if @currentView

    that = @
    @currentView = func() # func() should return a view
    @currentView.on 'navigate', => that.navigate(arguments...)
    @currentView.render()
