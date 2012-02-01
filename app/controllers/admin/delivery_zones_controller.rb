class Admin::DeliveryZonesController < AdminController
  respond_to :html, :xml, :json

  def index
    @delivery_zones = DeliveryZone.order(:code).page(params[:page])
    respond_with :admin, @delivery_zones
  end

  def show
    @delivery_zone = DeliveryZone.find(params[:id])
    @districts = @delivery_zone.districts.order(:code)
    @province = @delivery_zone.province
    respond_with :admin, @delivery_zone
  end

  def new
    @province = Province.find(params[:province_id])
    @delivery_zone = @province.delivery_zones.build
    respond_with :admin, @delivery_zone
  end

  def edit
    @delivery_zone = DeliveryZone.find(params[:id])
    respond_with :admin, @delivery_zone
  end

  def create
    @province = Province.find(params[:province_id])
    @delivery_zone = @province.delivery_zones.build
    @delivery_zone.attributes = params[:delivery_zone]
    if @delivery_zone.save
      flash[:notice] = "DeliveryZone created successfully."
    end

    respond_with :admin, @delivery_zone
  end

  def update
    @delivery_zone = DeliveryZone.find(params[:id])
    if @delivery_zone.update_attributes(params[:delivery_zone])
      flash[:notice] = "DeliveryZone updated successfully."
    end

    respond_with :admin, @delivery_zone
  end

  def destroy
    @delivery_zone = DeliveryZone.find(params[:id])
    if @delivery_zone.destroy
      flash[:notice] = "DeliveryZone destroyed successfully."
    end

    respond_with :admin, @delivery_zone
  end

end
