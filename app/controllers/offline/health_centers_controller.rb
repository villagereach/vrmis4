class Offline::HealthCentersController < ApplicationController
  respond_to :json

  def index
    synced_at = DateTime.now

    health_centers = Province.find_by_code(params[:province]).health_centers
    health_centers = health_centers.updated_since(params[:since])

    render :json => {
      'synced_at' => synced_at.strftime('%Y-%m-%d %H:%M:%S'),
      'health_centers' => health_centers.as_json(
        :only => [:id, :code, :population],
        :include => { :ideal_stock_amounts => {
          :methods => [:package_code],
          :only => [:quantity],
        }},
      ),
    }

  end

end
