var provinceCode = location.pathname.match(/^\/offline\/[^\/]+\/([^\/#]+)/)[1];

window.provinceDb = {
  id: "province-" + provinceCode + "-db",
  migrations: [
    { version: 1,
      migrate: function(transaction, next) {
        var dzStore = transaction.db.createObjectStore("delivery_zones");
        dzStore.createIndex("codeIndex", "code", { unique: true });

        var dStore = transaction.db.createObjectStore("districts");
        dStore.createIndex("codeIndex", "code", { unique: true });

        var hcStore = transaction.db.createObjectStore("health_centers");
        hcStore.createIndex("codeIndex", "code", { unique: true });

        var prodStore = transaction.db.createObjectStore("products");
        prodStore.createIndex("codeIndex", "code", { unique: true });

        var pkgStore = transaction.db.createObjectStore("packages");
        pkgStore.createIndex("codeIndex", "code", { unique: true });

        var scStore = transaction.db.createObjectStore("stock_cards");
        scStore.createIndex("codeIndex", "code", { unique: true });

        var etStore = transaction.db.createObjectStore("equipment_types");
        etStore.createIndex("codeIndex", "code", { unique: true });

        var hcvStore = transaction.db.createObjectStore("hc_visits");
        hcvStore.createIndex("codeIndex", "code", { unique: true });
        hcvStore.createIndex("monthIndex", "month", { unique: false });

        var dhcvStore = transaction.db.createObjectStore("dirty_hc_visits");
        dhcvStore.createIndex("codeIndex", "code", { unique: true });

        var ssStore = transaction.db.createObjectStore("sync_states");

        next();
      },
    },
  ],
};
