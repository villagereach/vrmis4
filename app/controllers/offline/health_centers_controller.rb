class Offline::HealthCentersController < OfflineController
  respond_to :json

  def index
    synced_at = DateTime.now

    health_centers = Province.find_by_code(params[:province]).health_centers
    health_centers = health_centers.updated_since(params[:since])

    hcs_json = health_centers.map do |hc|
      hcj = hc.as_json(
        :only => [:id, :code, :population],
        :methods => [:delivery_zone_code, :district_code],
      )

      hcj[:ideal_stock_amounts] = Hash[
        hc.ideal_stock_amounts.map {|isa| [isa.product_code, isa.quantity] }
      ]

      hcj
    end

    render :json => {
      'synced_at' => synced_at.utc.strftime('%Y-%m-%d %H:%M:%S'),
      'health_centers' => hcs_json,
    }

  end

end
