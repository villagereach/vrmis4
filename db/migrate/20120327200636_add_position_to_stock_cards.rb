class AddPositionToStockCards < ActiveRecord::Migration
  def change
    add_column :stock_cards, :position, :integer

    StockCard.scoped.each {|sc| sc.update_attributes({ :position => sc.id }) }
  end
end
