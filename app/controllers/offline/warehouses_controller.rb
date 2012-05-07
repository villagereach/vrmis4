class Offline::WarehousesController < OfflineController
  respond_to :json

  def index
    synced_at = DateTime.now

    province = Province.find_by_code(params[:province])
    warehouses = Warehouse.where(:province_id => province.id)
    warehouses = warehouses.updated_since(params[:since])

    render :json => {
      'synced_at' => synced_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      'warehouses' => warehouses.as_json(:only => [:code]),
    }
  end

end
