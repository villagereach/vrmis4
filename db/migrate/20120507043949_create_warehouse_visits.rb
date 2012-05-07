class CreateWarehouseVisits < ActiveRecord::Migration
  def change
    create_table :warehouse_visits do |t|
      t.string   :code

      t.string   :province_code
      t.string   :warehouse_code
      t.date     :month

      t.text     :data

      t.timestamps
    end

    add_index :warehouse_visits, :code
    add_index :warehouse_visits, :month
    add_index :warehouse_visits, [:province_code, :month]
    add_index :warehouse_visits, [:warehouse_code, :month]
  end
end
