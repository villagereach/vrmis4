class CreateEquipmentTypes < ActiveRecord::Migration
  def change
    create_table :equipment_types do |t|
      t.string :code

      t.timestamps
    end

    add_index :equipment_types, :code
  end

end
