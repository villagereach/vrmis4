class CreateStockCards < ActiveRecord::Migration
  def change
    create_table :stock_cards do |t|
      t.string   :code

      t.timestamps
    end

    add_index :stock_cards, :code
  end

end
