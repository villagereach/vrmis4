class RedesignConfigSnapshots < ActiveRecord::Migration
  def up
    drop_table :config_snapshots

    create_table :config_snapshots do |t|
      t.string   :province_code
      t.date     :month
      t.text     :data

      t.timestamps
    end

    add_index :config_snapshots, [:province_code, :month]
  end

  def down
    drop_table :config_snapshots

    create_table :config_snapshots do |t|
      t.date     :month
      t.text     :provinces
      t.text     :health_centers
      t.text     :products
      t.text     :stock_cards
      t.text     :equipment_types

      t.timestamps
    end

    add_index :config_snapshots, :month
  end
end
