class Admin::HealthCentersController < AdminController
  respond_to :html, :xml, :json

  def index
    @health_centers = HealthCenter.order(:code).page(params[:page])
    respond_with :admin, @health_centers
  end

  def show
    @health_center = HealthCenter.find(params[:id])
    @ideal_stock_amounts = @health_center.ideal_stock_amounts
    @district = @health_center.district
    @delivery_zone = @district.delivery_zone
    @province = @delivery_zone.province
    respond_with :admin, @health_center
  end

  def new
    @district = District.find(params[:district_id])
    @health_center = @district.health_centers.build
    @delivery_zone = @district.delivery_zone
    @province = @delivery_zone.province
    respond_with :admin, @health_center
  end

  def edit
    @health_center = HealthCenter.find(params[:id])
    @ideal_stock_amounts = @health_center.ideal_stock_amounts
    @district = @health_center.district
    @delivery_zone = @district.delivery_zone
    @province = @delivery_zone.province
    respond_with :admin, @health_center
  end

  def create
    @district = District.find(params[:district_id])
    @health_center = @district.health_centers.build
    @health_center.attributes = params[:health_center]
    if @health_center.save
      flash[:notice] = "HealthCenter created successfully."
    end

    respond_with :admin, @health_center
  end

  def update
    @health_center = HealthCenter.find(params[:id])
    if @health_center.update_attributes(params[:health_center])
      flash[:notice] = "HealthCenter updated successfully."
    end

    respond_with :admin, @health_center
  end

  def destroy
    @health_center = HealthCenter.find(params[:id])
    if @health_center.destroy
      flash[:notice] = "HealthCenter destroyed successfully."
    end

    redirect_to [:admin, @health_center.district]
  end

end
