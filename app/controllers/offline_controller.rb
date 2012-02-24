class OfflineController < ApplicationController
  layout 'offline'

  ACCESS_CODES = {
    'nampula'      => 'vacina',
    'niassa'       => 'seringa',
    'cabo-delgado' => 'geleira',
    'maputo'       => 'aldeia',
    'gaza'         => 'medicina',

  }

  def index
    @province = Province.find_by_code(params[:province])
    @access_code = ACCESS_CODES[@province.code];
    @delivery_zones = @province.delivery_zones.includes(:districts)
    @health_centers = @delivery_zones.map(&:districts).flatten.map(&:health_centers).flatten
    @products = Product.includes(:packages)
  end
end
