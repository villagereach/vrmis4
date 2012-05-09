class Offline::HcVisitsController < OfflineController
  respond_to :json

  before_filter :authenticate, :only => :update

  def index
    synced_at = DateTime.now

    hc_visits = Province.find_by_code(params[:province]).hc_visits
    hc_visits = hc_visits.updated_since(params[:since])

    if params[:months]
      months = params[:months].split(/,/).map {|m| m + '-01'}
      hc_visits = hc_visits.where(:month => months)
    end

    # [].to_json(...) calls :as_json on each obj which would deserialize and reserialize
    visits_json = hc_visits.map {|hcv| hcv.to_json(:schema => :offline)}
    render :json => <<-END
      {
        "synced_at":"#{synced_at.utc.strftime('%Y-%m-%d %H:%M:%S')}",
        "hc_visits":[#{visits_json.join(',')}]
      }
    END

  end

  def update
    hc_visit = HcVisit.find_or_initialize_by_code(params[:code])
    dz = DeliveryZone.find_by_code(params[:data]['delivery_zone_code'])

    params[:data].delete('state')
    hc_visit.data = params[:data]
    hc_visit.month = hc_visit.data['month'] + '-01'
    hc_visit.health_center_code = hc_visit.data['health_center_code']
    hc_visit.province_code = dz.province.code

    if hc_visit.save
      render :json => { 'result' => 'success' }
    else
      render :json => { 'result' => 'error', 'errors' => hc_visit.errors.full_messages }
    end
  end

end
