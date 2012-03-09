class Offline::DeliveryZonesController < ApplicationController
  respond_to :json

  def index
    synced_at = DateTime.now

    delivery_zones = Province.find_by_code(params[:province]).delivery_zones
    delivery_zones = delivery_zones.updated_since(params[:since])

    render :json => {
      'synced_at' => synced_at.strftime('%Y-%m-%d %H:%M:%S'),
      'delivery_zones' => delivery_zones.as_json(
        :only => [:id, :code],
        :include => { :districts => {
          :only => [:id, :code],
          :methods => [:health_center_codes],
        }},
      ),
    }
  end

end
