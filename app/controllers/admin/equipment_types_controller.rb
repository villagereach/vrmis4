class Admin::EquipmentTypesController < AdminController
  respond_to :html, :xml, :json

  def index
    @equipment_types = EquipmentType.order(:position).page(params[:page])
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

  def sort
    @equipment_types = EquipmentType.scoped
    @equipment_types.each do |et|
      et.position = params['equipment_type'].index(et.id.to_s) + 1
      et.save
    end

    render :text => nil
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
