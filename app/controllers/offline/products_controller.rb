class Offline::ProductsController < OfflineController
  respond_to :json

  def index
    synced_at = DateTime.now

    products = Product.updated_since(params[:since])
    packages = Package.updated_since(params[:since])
    stock_cards = StockCard.updated_since(params[:since])
    equipment_types = EquipmentType.updated_since(params[:since])

    render :json => {
      'synced_at' => synced_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      'products' => products.as_json(
        :only => [:code, :position, :product_type, :trackable],
      ),
      'packages' => packages.as_json(
        :only => [:code, :position, :quantity, :primary],
        :methods => [:product_code],
      ),
      'stock_cards' => stock_cards.as_json(
        :only => [:code, :position],
      ),
      'equipment_types' => equipment_types.as_json(
        :only => [:code, :position],
      ),
    }
  end

end
