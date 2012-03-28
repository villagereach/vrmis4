class AddPositionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :position, :integer

    Product.scoped.each {|p| p.update_attributes({ :position => p.id }) }
  end

end
