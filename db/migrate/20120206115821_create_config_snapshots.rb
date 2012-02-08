class CreateConfigSnapshots < ActiveRecord::Migration
  def change
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
