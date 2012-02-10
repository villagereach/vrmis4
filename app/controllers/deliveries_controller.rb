class DeliveriesController < ApplicationController
  layout 'deliveries'

  before_filter :set_locale


  def index
    @province = Province.first
    @delivery_zones = @province.delivery_zones
  end


  private 

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

end
