class CreateHcVisits < ActiveRecord::Migration
  def change
    create_table :hc_visits do |t|
      t.string   :code

      t.string   :province_code
      t.string   :health_center_code
      t.date     :month

      t.text     :data

      t.timestamps
    end

    add_index :hc_visits, :code
    add_index :hc_visits, :month
    add_index :hc_visits, [:province_code, :month]
    add_index :hc_visits, [:health_center_code, :month]
  end

end
