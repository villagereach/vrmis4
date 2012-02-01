class Package < ActiveRecord::Base
  belongs_to :product
  has_many :ideal_stock_amounts, :dependent => :destroy

  before_validation { self.code = code && code.parameterize }

  validates :product, :presence => true
  validates :code, :presence => true, :uniqueness => true
  validates :quantity, :numericality => true

end
