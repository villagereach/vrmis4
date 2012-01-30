class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.references :delivery_zone

      t.string   :code
      t.integer  :population
      t.float    :latitude
      t.float    :longitude

      t.timestamps
    end

    add_index :districts, :code
  end

end
