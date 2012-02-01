class CreateIdealStockAmounts < ActiveRecord::Migration
  def change
    create_table :ideal_stock_amounts do |t|
      t.references :health_center
      t.references :package

      t.integer  :quantity

      t.timestamps
    end

    add_index :ideal_stock_amounts, :health_center_id
  end

end
