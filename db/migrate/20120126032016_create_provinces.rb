class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.string   :code
      t.integer  :population
      t.float    :latitude
      t.float    :longitude

      t.timestamps
    end

    add_index :provinces, :code
  end

end
