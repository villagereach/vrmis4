class Offline::DeliveryZonesController < ApplicationController
  respond_to :json

  def index
    synced_at = DateTime.now

    province = Province.find_by_code(params[:province])
    delivery_zones = province.delivery_zones.updated_since(params[:since])
    districts = province.districts.updated_since(params[:since])

    render :json => {
      'synced_at' => synced_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      'delivery_zones' => delivery_zones.as_json(
        :only => [:id, :code],
      ),
      'districts' => districts.as_json(
        :only => [:id, :code],
        :methods => [:delivery_zone_code],
      ),
    }
  end

end
