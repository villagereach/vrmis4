class Admin::EquipmentTypesController < AdminController
  respond_to :html, :xml, :json

  def index
    @equipment_types = EquipmentType.order(:code).page(params[:page])
    respond_with :admin, @equipment_types
  end

  def show
    @equipment_type = EquipmentType.find(params[:id])
    respond_with :admin, @equipment_type
  end

  def new
    @equipment_type = EquipmentType.new
    respond_with :admin, @equipment_type
  end

  def edit
    @equipment_type = EquipmentType.find(params[:id])
    respond_with :admin, @equipment_type
  end

  def create
    @equipment_type = EquipmentType.new
    @equipment_type.attributes = params[:equipment_type]
    if @equipment_type.save
      flash[:notice] = "EquipmentType created successfully."
    end

    respond_with :admin, @equipment_type
  end

  def update
    @equipment_type = EquipmentType.find(params[:id])
    if @equipment_type.update_attributes(params[:equipment_type])
      flash[:notice] = "EquipmentType updated successfully."
    end

    respond_with :admin, @equipment_type
  end

  def destroy
    @equipment_type = EquipmentType.find(params[:id])
    if @equipment_type.destroy
      flash[:notice] = "EquipmentType destroyed successfully."
    end

    respond_with :admin, @equipment_type
  end

end
