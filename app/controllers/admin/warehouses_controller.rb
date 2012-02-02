class Admin::WarehousesController < AdminController
  respond_to :html, :xml, :json

  def index
    @warehouses = Warehouse.order(:code).page(params[:page])
    respond_with :admin, @warehouses
  end

  def show
    @warehouse = Warehouse.find(params[:id])
    @province = @warehouse.province
    respond_with :admin, @warehouse
  end

  def edit
    @warehouse = Warehouse.find(params[:id])
    @province = @warehouse.province
    respond_with :admin, @warehouse
  end

  def update
    @warehouse = Warehouse.find(params[:id])
    if @warehouse.update_attributes(params[:warehouse])
      flash[:notice] = "Warehouse updated successfully."
    end

    respond_with :admin, @warehouse
  end

end
