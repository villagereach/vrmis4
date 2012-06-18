class OfflineController < ApplicationController
  layout 'offline'

  before_filter :set_locale

  def index
    @mode = params[:mode]
    @locale = params[:locale]
    @language = Language.find_by_locale(@locale)
    @province = Province.find_by_code(params[:province])

    if params[:mode] == 'offline'
      @manifest = "/#{@mode}/#{@locale}/#{@province.code}/manifest"
    end
  end

  def manifest
    digest = Rails.application.config.assets.digest
    digests = Rails.application.config.assets.digests

    md5sum = Digest::MD5.new

    files = []
    css = ['application.css', 'offline.css']
    javascript = ['application.js', 'offline.js']
    images = ['favicon.ico', 'icons-16px.png', 'vr-mis-logo-small.png']
    [*css, *javascript, *images].each do |name|
      asset = Rails.application.assets[name]
      files << '/assets/' + (digest ? digests[asset.logical_path] : asset.logical_path)
      md5sum << asset.digest
      if Rails.env.development?
        asset.dependencies.each do |a|
          files << '/assets/' + (digest ? digests[a.logical_path] : a.logical_path)
          md5sum << a.digest
        end
      end
    end

    language = Language.find_by_locale(params[:locale])
    lang_mtime = language.updated_at.strftime('-%s')
    files << "/offline/#{params[:locale]}/#{params[:province]}/translations#{lang_mtime}.js"
    md5sum << lang_mtime

    header = "CACHE MANIFEST\n# #{md5sum.hexdigest}"
    cache = files.join("\n")
    network = "NETWORK:\n/"

    render :text => [header,cache,network].join("\n\n"), :content_type => 'text/cache-manifest'
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


  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

end
