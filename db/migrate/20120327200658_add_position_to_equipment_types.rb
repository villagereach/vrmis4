class AddPositionToEquipmentTypes < ActiveRecord::Migration
  def change
    add_column :equipment_types, :position, :integer

    EquipmentType.scoped.each {|et| et.update_attributes({ :position => et.id }) }
  end

end
