class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|
      t.references :province

      t.string   :code

      t.timestamps
    end

    add_index :warehouses, :code
  end

end
