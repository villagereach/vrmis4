class Offline::ProductsController < ApplicationController
  respond_to :json

  def index
    synced_at = DateTime.now

    products = Product.updated_since(params[:since])
    stock_cards = StockCard.updated_since(params[:since])
    equipment_types = EquipmentType.updated_since(params[:since])

    render :json => {
      'synced_at' => synced_at.strftime('%Y-%m-%d %H:%M:%S'),
      'products' => products.as_json(
        :only => [:code, :product_type, :trackable],
        :include => { :packages => {
          :only => [:code, :quantity, :primary],
        }},
      ),
      'stock_cards' => stock_cards.as_json(
        :only => [:code],
      ),
      'equipment_types' => equipment_types.as_json(
        :only => [:code],
      ),
    }
  end

end
