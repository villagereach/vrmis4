class Package < ActiveRecord::Base
  belongs_to :product
  has_many :ideal_stock_amounts, :dependent => :destroy

  before_validation { self.code = code && code.parameterize }

  validates :code, :presence => true, :uniqueness => true
  validates :product, :presence => true

end
