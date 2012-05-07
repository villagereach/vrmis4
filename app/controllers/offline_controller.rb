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
    @access_code = ACCESS_CODES[@province.code]
  end

  def reset
    @province = Province.find_by_code(params[:province])
  end

  def ping
    render :json => 'pong'.to_json
  end

  def login
    if current_user
      render :json => 'OK'.to_json
    else
      request_http_auth
    end
  end

end
