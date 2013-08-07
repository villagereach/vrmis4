class AdminController < ApplicationController
  layout 'admin'

  before_filter :require_admin, :except => :login


  def login
    render :layout => 'application'
  end

  def require_admin
    request_http_auth unless authenticate.try(:role) == 'admin'
  end

  def dump
    to_month = params[:to] ? Date.parse(params[:to]) : Date.today
    from_month = params[:from] ? Date.parse(params[:from]) : to_month - 6.months
    hcvs=HcVisit.order("month, province_code, health_center_code").where(["month >= ? AND month <= ?",from_month,to_month]).all
    model_headers = %w(month code health_center_code updated_at visited_at province_code)
    chain_headers = %w(district_code delivery_zone_code)
    data_headers = []
    all_data = []
    hcvs.each_with_index do |hcv, idx|
      flat_data = flat_hash(hcv.data.except("refrigerators")).merge(flat_hash(hashify_array("refrigerators", hcv.data["refrigerators"])))
      data_headers = (data_headers + chain_headers+ flat_data.keys).uniq  #add new keys
#      binding.pry
      puts "head size #{data_headers.size}"
      data_row = model_headers.map{|h| hcv.send(h) }
      data_row += [hcv.health_center.district.code, hcv.health_center.district.delivery_zone.code] 
      data_row += data_headers.map{|h| flat_data[h]}
      puts "row size #{data_row.size}"
      all_data << data_row
    end
    all_data.unshift(model_headers + data_headers)
    full_csv = all_data.map{|drow|  drow.map{|dp| csv_quote(dp)}.join(",")}.join("\n")
    render :text=> full_csv
  end

  
    
  private
  
  def flat_hash(hash, k = [])
    return {k.join(".") => hash} unless hash.is_a?(Hash)
    hash.inject({}){ |h, v| h.merge! flat_hash(v[-1], k + [v[0]]) }
  end

  def csv_quote(x)
    x ||= ""
    '"'+x.to_s.gsub(/"/,"'")+'"'
  end
  
  def hashify_array(key, a)
    out = {}
    a ||= []
    a.each_with_index do |e, idx|
      out[key.to_s + (idx+1).to_s] = e
    end
    out
  end
end
