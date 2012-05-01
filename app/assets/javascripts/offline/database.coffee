provinceCode = location.pathname.match(/^\/offline\/[^\/]+\/([^\/#]+)/)[1]

window.provinceDb =
  id: "province-#{provinceCode}-db"
  migrations: [
    { version: 1, migrate: (transaction, next) ->
      dzStore = transaction.db.createObjectStore 'delivery_zones'
      dzStore.createIndex 'codeIndex', 'code', unique: true

      dStore = transaction.db.createObjectStore 'districts'
      dStore.createIndex 'codeIndex', 'code', unique: true

      hcStore = transaction.db.createObjectStore 'health_centers'
      hcStore.createIndex 'codeIndex', 'code', unique: true

      prodStore = transaction.db.createObjectStore 'products'
      prodStore.createIndex 'codeIndex', 'code', unique: true

      pkgStore = transaction.db.createObjectStore 'packages'
      pkgStore.createIndex 'codeIndex', 'code', unique: true

      scStore = transaction.db.createObjectStore 'stock_cards'
      scStore.createIndex 'codeIndex', 'code', unique: true

      etStore = transaction.db.createObjectStore 'equipment_types'
      etStore.createIndex 'codeIndex', 'code', unique: true

      hcvStore = transaction.db.createObjectStore 'hc_visits'
      hcvStore.createIndex 'codeIndex', 'code', unique: true
      hcvStore.createIndex 'monthIndex', 'month', unique: false

      dhcvStore = transaction.db.createObjectStore 'dirty_hc_visits'
      dhcvStore.createIndex 'codeIndex', 'code', unique: true

      ssStore = transaction.db.createObjectStore 'sync_states'

      next()
    }
  ]
