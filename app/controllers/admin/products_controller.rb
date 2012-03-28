class Admin::ProductsController < AdminController
  respond_to :html, :xml, :json

  def index
    @products = Product.order(:position).page(params[:page])
    respond_with :admin, @products
  end

  def show
    @product = Product.find(params[:id])
    @packages = @product.packages
    respond_with :admin, @product
  end

  def new
    @product = Product.new
    respond_with :admin, @product
  end

  def edit
    @product = Product.find(params[:id])
    respond_with :admin, @product
  end

  def create
    @product = Product.new
    @product.attributes = params[:product]
    if @product.save
      flash[:notice] = "Product created successfully."
    end

    respond_with :admin, @product
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(params[:product])
      flash[:notice] = "Product updated successfully."
    end

    respond_with :admin, @product
  end

  def destroy
    @product = Product.find(params[:id])
    if @product.destroy
      flash[:notice] = "Product destroyed successfully."
    end

    respond_with :admin, @product
  end

end
