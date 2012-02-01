class CreateDeliveryZones < ActiveRecord::Migration
  def change
    create_table :delivery_zones do |t|
      t.references :province

      t.string   :code
      t.float    :latitude
      t.float    :longitude

      t.timestamps
    end

    add_index :delivery_zones, :code
  end

end
