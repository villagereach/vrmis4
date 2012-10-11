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

    data = cleanup_firefox_type_bug(params[:data])
    %w(id state screenStates).each {|f| data.delete(f) }

    #--------------------------------------------------------------------------#
    # additional cleanup (to fix in offline js code still):
    #------------------------------------------------------
    data['observations']['verified_by_title'] ||= 'Field Officer'

    if data['visited'] == true
      data['non_visit_reason'] = nil
      data['other_non_visit_reason'] = nil
    elsif data['visited'] == false
      data.delete 'refrigerators'
      data.delete 'epi_inventory'
      data.delete 'rdt_inventory'
      data.delete 'equipment_status'
      data.delete 'stock_cards'
      data['visited_at'] = nil
      data['vehicle_id'] = nil
    else
      # don't do anything if 'visited' is null/unknown (just in case)
    end

    if data['refrigerators']
      data['refrigerators'].each do |refrigerator|
        running_problems = refrigerator['running_problems']
        if running_problems && running_problems.empty?
          refrigerator['running_problems'] = nil
        end
      end
      data['refrigerators'].reject! {|r| r.values.none? }
      data.delete('refrigerators') if data['refrigerators'].empty?
    end

    #--------------------------------------------------------------------------#

    hc_visit.data = data

    if hc_visit.save
      render :json => { 'result' => 'success' }
    else
      render :json => { 'result' => 'error', 'errors' => hc_visit.errors.full_messages }
    end
  end


  private

  def cleanup_firefox_type_bug(data)
    # firefox was returning 'text' as the HTML element's type for 'number'
    # fields and was thus serializing its data as strings instead of numbers.
    # fixed in offline javascript code but may take 1-2 months to propagate
    screens = %w(epi_inventory rdt_inventory rdt_stock epi_stock
      full_vac_tally child_vac_tally adult_vac_tally)

    screens.each do |screen|
      next if data[screen].nil?
      data[screen].each do |k1,v1|
        v1.each {|k2,v2| data[screen][k1][k2] = (v2 =~ /^(\d+)$/ ? $1.to_i : v2) }
      end
    end

    (data['refrigerators']||[]).each do |refrigerator|
      refrigerator['temperature'] = case refrigerator['temperature']
        when /^(-?[\d]+)$/ then $1.to_i
        when /^(-?[\d]+\.[\d]+)$/ then $1.to_f
        else refrigerator['temperature']
      end
    end

    data
  end

end
