class window.OfflineRouter extends Backbone.Router
  routes:
    ''                                : 'root'
    'login'                           : 'userLoginForm'
    'home'                            : 'mainUserPage'
    'select_hc/:month/:dzcode'        : 'selectHcPage'
    'hc_visits/:code'                 : 'hcVisitPage'
    'hc_visits/:code/edit'            : 'editHcVisitPage'
    'hc_visits/:code/:tab'            : 'hcVisitPage'
    'warehouse_visits/:code'          : 'warehouseVisitPage'
    'warehouse_visits/:code/edit'     : 'editWarehouseVisitPage'
    'warehouse_visits/:code/ideal'    : 'idealWarehouseVisitPage'
    'reports/adhoc'                   : 'adhocReportsPage'
    'reports/summary/:month/*scoping' : 'summaryReportPage'
    'sync'                            : 'syncPage'
    'sync/:action'                    : 'syncPage'
    'reset'                           : 'resetDatabase'
    '*url'                            : 'err404'

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
      @navigate 'sync/pull', trigger: true
      return

    @mainView ?= new Views.Users.Main
      deliveryZones: @app.deliveryZones
      months: @app.months
    @display => @mainView

  selectHcPage: (month, dzCode) ->
    @display => new Views.Users.SelectHc
      month: month
      deliveryZone: @app.deliveryZones.get(dzCode)
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

  idealWarehouseVisitPage: (visitCode) ->
    result = visitCode.match(/^(.+?)-(\d{4}-\d{2})$/)
    @display => new Views.WarehouseVisits.Ideal
      month: result[2]
      deliveryZone: @app.deliveryZones.get(result[1])
      products: @app.products
      packages: @app.packages

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
      warehouse = @app.warehouses.at(0) # only one warehouse per province
      warehouseVisit.set 'warehouse_code', warehouse.get('code')
      @app.dirtyWarehouseVisits.add(warehouseVisit)

    @display => new Views.WarehouseVisits[if warehouseVisit.isEditable() then 'Edit' else 'Show']
      warehouseVisit: warehouseVisit
      warehouse: @app.warehouses.at(0)
      deliveryZone: @app.deliveryZones.get(warehouseVisit.get('delivery_zone_code'))
      products: @app.products
      packages: @app.packages

  adhocReportsPage: ->
    @display => new Views.Reports.Adhoc
      months: @app.months

  summaryReportPage: (month, scoping) ->
    @display => new Views.Reports.Summary
      products: @app.products
      healthCenters: @app.healthCenters
      hcVisits: @app.hcVisits
      visitMonths: @app.months
      scoping: scoping
      month: month
      stockCards: @app.stockCards
      packages: @app.packages

  resetDatabase: ->
    window.location = window.location.pathname.replace /\/?$/, '/reset'

  syncPage: (action) ->
    syncView = new Views.Sync.Overview
      syncState: @app.syncState
      dirtyHcVisits: @app.dirtyHcVisits
      dirtyWarehouseVisits: @app.dirtyWarehouseVisits

    @display => syncView

    syncView.pullDataDialog() if action is 'pull'
    syncView.pushVisitsDialog() if action is 'push'

  err404: (url) ->
    window.alert("unknown url #{url}")

  display: (func) ->
    @currentView.close() if @currentView

    that = @
    @currentView = func() # func() should return a view
    @currentView.on 'navigate', => that.navigate(arguments...)
    @currentView.render()
