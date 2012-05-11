class AddIsaCalcToProducts < ActiveRecord::Migration
  def change
    add_column :products, :isa_calc, :text
  end
end
