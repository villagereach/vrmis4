class IdealStockAmount < ActiveRecord::Base
  belongs_to :health_center, :touch => true
  belongs_to :product

  validates :health_center, :presence => true
  validates :product, :presence => true
  validates :product_id, :uniqueness => { :scope => :health_center_id }
  validates :quantity, :numericality => true

  def product_code
    product.code
  end

end
