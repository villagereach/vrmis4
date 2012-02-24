class OfflineController < ApplicationController
  layout 'offline'

  def index
    params[:province] ||= 'niassa'
    @access_code = 'foobar'
    @province = Province.find_by_code(params[:province])
    @delivery_zones = @province.delivery_zones.includes(:districts)
    @health_centers = @delivery_zones.map(&:districts).flatten.map(&:health_centers).flatten
    @products = Product.includes(:packages)
  end
end
