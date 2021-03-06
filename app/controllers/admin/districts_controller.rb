class Admin::DistrictsController < AdminController
  respond_to :html, :xml, :json

  def index
    @districts = District.order(:code).page(params[:page])
    respond_with :admin, @districts
  end

  def show
    @district = District.find(params[:id])
    @health_centers = @district.health_centers.order(:code)
    @delivery_zone = @district.delivery_zone
    @province = @delivery_zone.province
    respond_with :admin, @district
  end

  def new
    @delivery_zone = DeliveryZone.find(params[:delivery_zone_id])
    @district = @delivery_zone.districts.build
    @province = @delivery_zone.province
    respond_with :admin, @district
  end

  def edit
    @district = District.find(params[:id])
    @delivery_zone = @district.delivery_zone
    @province = @delivery_zone.province
    respond_with :admin, @district
  end

  def create
    @delivery_zone = DeliveryZone.find(params[:delivery_zone_id])
    @district = @delivery_zone.districts.build
    @province = @delivery_zone.province
    @district.attributes = params[:district]
    if @district.save
      flash[:notice] = "District created successfully."
    end

    respond_with :admin, @district
  end

  def update
    @district = District.find(params[:id])
    @delivery_zone = @district.delivery_zone
    @province = @delivery_zone.province
    if @district.update_attributes(params[:district])
      flash[:notice] = "District updated successfully."
    end

    respond_with :admin, @district
  end

  def destroy
    @district = District.find(params[:id])
    if @district.destroy
      flash[:notice] = "District destroyed successfully."
    end

    redirect_to [:admin, @district.delivery_zone]
  end

end
