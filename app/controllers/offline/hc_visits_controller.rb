class Offline::HcVisitsController < ApplicationController
  respond_to :json

  def index
    synced_at = DateTime.now

    hc_visits = Province.find_by_code(params[:province]).hc_visits
    hc_visits = hc_visits.updated_since(params[:since])

    if params[:months]
      months = params[:months].split(/,/).map {|m| m + '-01'}
      hc_visits = hc_visits.where(:month => months)
    end

    render :json => <<-END.strip_heredoc
      {
        "synced_at":"#{synced_at.utc.strftime('%Y-%m-%d %H:%M:%S')}",
        "hc_visits":[#{hc_visits.map(&:data_json).join(',')}]
      }
    END

  end

end
