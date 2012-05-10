class Offline::ProductsController < OfflineController
  respond_to :json

  def index
    synced_at = DateTime.now

    products = Product.updated_since(params[:since])
    packages = Package.updated_since(params[:since])
    stock_cards = StockCard.updated_since(params[:since])
    equipment_types = EquipmentType.updated_since(params[:since])

    render :json => {
      'synced_at'       => synced_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      'products'        => products.as_json(:schema => :offline),
      'packages'        => packages.as_json(:schema => :offline),
      'stock_cards'     => stock_cards.as_json(:schema => :offline),
      'equipment_types' => equipment_types.as_json(:schema => :offline),
    }
  end

end
