class Offline::WarehouseVisitsController < OfflineController
  respond_to :json

  before_filter :authenticate, :only => :update

  def index
    synced_at = DateTime.now

    warehouse_visits = Province.find_by_code(params[:province]).warehouse_visits
    warehouse_visits = warehouse_visits.updated_since(params[:since])

    if params[:months]
      months = params[:months].split(/,/).map {|m| m + '-01'}
      warehouse_visits = warehouse_visits.where(:month => months)
    end

    # [].to_json(...) calls :as_json on each obj which would deserialize and reserialize
    visits_json = warehouse_visits.map {|wv| wv.to_json(:schema => :offline)}
    render :json => <<-END
      {
        "synced_at":"#{synced_at.utc.strftime('%Y-%m-%d %H:%M:%S')}",
        "warehouse_visits":[#{visits_json.join(',')}]
      }
    END
  end

  def update
    warehouse_visit = WarehouseVisit.find_or_initialize_by_code(params[:code])
    warehouse = Warehouse.find_by_code(params[:data]['warehouse_code'])

    params[:data].delete('state')
    warehouse_visit.data = params[:data]
    warehouse_visit.month = warehouse_visit.data['month'] + '-01'
    warehouse_visit.warehouse_code = warehouse_visit.data['warehouse_code']
    warehouse_visit.delivery_zone_code = warehouse_visit.data['delivery_zone_code']
    warehouse_visit.province_code = warehouse.province.code

    if warehouse_visit.save
      render :json => { 'result' => 'success' }
    else
      render :json => { 'result' => 'error', 'errors' => warehouse_visit.errors.full_messages }
    end
  end

end
