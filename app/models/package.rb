class Package < ActiveRecord::Base
  belongs_to :product
  has_many :ideal_stock_amounts

end
