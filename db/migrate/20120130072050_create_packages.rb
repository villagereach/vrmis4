class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.references :product

      t.string   :code
      t.integer  :quantity
      t.boolean  :primary

      t.timestamps
    end

    add_index :packages, :code
  end

end
