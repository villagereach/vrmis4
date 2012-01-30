class Product < ActiveRecord::Base
  belongs_to :product_type
  has_many :packages

end
