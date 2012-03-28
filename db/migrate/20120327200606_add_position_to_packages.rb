class AddPositionToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :position, :integer

    Package.scoped.each {|p| p.update_attributes({ :position => p.id }) }
  end

end
