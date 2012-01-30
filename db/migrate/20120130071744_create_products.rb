class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :product_type

      t.string   :code

      t.timestamps
    end

    add_index :products, :code
  end

end
