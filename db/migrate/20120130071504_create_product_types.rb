class CreateProductTypes < ActiveRecord::Migration
  def change
    create_table :product_types do |t|
      t.string   :code
      t.boolean  :trackable

      t.timestamps
    end

    add_index :product_types, :code
  end

end
