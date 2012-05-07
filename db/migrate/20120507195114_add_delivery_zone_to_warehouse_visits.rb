class AddDeliveryZoneToWarehouseVisits < ActiveRecord::Migration
  def change
    add_column :warehouse_visits, :delivery_zone_code, :string
    add_index :warehouse_visits, [:delivery_zone_code, :month]

    WarehouseVisit.scoped.each do |warehouse_visit|
      warehouse_visit.update_attributes({
        :delivery_zone_code => warehouse_visit.data['delivery_zone_code'],
      })
    end
  end
end
