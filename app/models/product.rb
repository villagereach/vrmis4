class Product < ActiveRecord::Base
  has_many :packages

  PRODUCT_TYPES = ['fuel', 'safety', 'syringe', 'test', 'vaccine']

  def self.product_types
    PRODUCT_TYPES
  end

end
