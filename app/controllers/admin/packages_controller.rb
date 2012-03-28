class Admin::PackagesController < AdminController
  respond_to :html, :xml, :json

  def index
    @packages = Package.order(:position).page(params[:page])
    respond_with :admin, @packages
  end

  def show
    @package = Package.find(params[:id])
    @product = @package.product
    respond_with :admin, @package
  end

  def new
    @product = Product.find(params[:product_id])
    @package = @product.packages.build
    @package.primary = true if @product.packages.none?(&:primary)
    respond_with :admin, @package
  end

  def edit
    @package = Package.find(params[:id])
    @product = @package.product
    respond_with :admin, @package
  end

  def create
    @product = Product.find(params[:product_id])
    @package = @product.packages.build
    @package.attributes = params[:package]
    if @package.save
      flash[:notice] = "Package created successfully."
    end

    respond_with :admin, @package
  end

  def update
    @package = Package.find(params[:id])
    @product = @package.product
    if @package.update_attributes(params[:package])
      flash[:notice] = "Package updated successfully."
    end

    respond_with :admin, @package
  end

  def destroy
    @package = Package.find(params[:id])
    if @package.destroy
      flash[:notice] = "Package destroyed successfully."
    end

    redirect_to [:admin, @package.product]
  end

end
