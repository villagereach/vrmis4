class Product < ActiveRecord::Base
  has_many :packages, :dependent => :destroy

  PRODUCT_TYPES = ['fuel', 'safety', 'syringe', 'test', 'vaccine']

  before_validation { self.code = code && code.parameterize }

  validates :code, :presence => true, :uniqueness => true


  def self.product_types
    PRODUCT_TYPES
  end

end
