class Offline::HealthCentersController < OfflineController
  respond_to :json

  def index
    synced_at = DateTime.now

    health_centers = Province.find_by_code(params[:province]).health_centers
    health_centers = health_centers.updated_since(params[:since])

    render :json => {
      'synced_at'      => synced_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      'health_centers' => health_centers.as_json(:schema => :offline),
    }

  end

end
