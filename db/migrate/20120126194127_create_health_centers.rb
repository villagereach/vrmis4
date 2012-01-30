class CreateHealthCenters < ActiveRecord::Migration
  def change
    create_table :health_centers do |t|
      t.references :district

      t.string   :code
      t.integer  :population
      t.float    :latitude
      t.float    :longitude

      t.timestamps
    end

    add_index :health_centers, :code
  end

end
