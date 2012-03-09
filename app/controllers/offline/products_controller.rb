class Offline::ProductsController < ApplicationController
  respond_to :json

  def index
    synced_at = DateTime.now

    products = Product.updated_since(params[:since])

    render :json => {
      'synced_at' => synced_at.strftime('%Y-%m-%d %H:%M:%S'),
      'products' => products.as_json(
        :only => [:code, :product_type, :trackable],
        :include => { :packages => {
          :only => [:code, :quantity, :primary],
        }},
      ),
    }
  end

end
