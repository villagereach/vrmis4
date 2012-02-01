class Admin::ProvincesController < AdminController
  respond_to :html, :xml, :json

  def index
    @provinces = Province.order(:code).page(params[:page])
    respond_with :admin, @provinces
  end

  def show
    @province = Province.find(params[:id])
    @delivery_zones = @province.delivery_zones.order(:code)
    @warehouse = @province.warehouse
    respond_with :admin, @province
  end

  def new
    @province = Province.new
    respond_with :admin, @province
  end

  def edit
    @province = Province.find(params[:id])
    respond_with :admin, @province
  end

  def create
    @province = Province.new
    @province.attributes = params[:province]
    @warehouse = @province.build_warehouse(
      :code => "#{@province.code}-warehouse"
    )

    if @province.save
      flash[:notice] = "Province created successfully."
    end

    respond_with :admin, @province
  end

  def update
    @province = Province.find(params[:id])
    if @province.update_attributes(params[:province])
      flash[:notice] = "Province updated successfully."
    end

    respond_with :admin, @province
  end

  def destroy
    @province = Province.find(params[:id])
    if @province.destroy
      flash[:notice] = "Province destroyed successfully."
    end

    respond_with :admin, @province
  end

end
