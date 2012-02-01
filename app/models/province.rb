class Province < ActiveRecord::Base
  has_many :delivery_zones, :dependent => :destroy
  has_many :districts, :through => :delivery_zones
  has_one :warehouse, :dependent => :destroy

  before_validation { self.code = code && code.parameterize }

  validates :code, :presence => true, :uniqueness => true
  validates :population, :numericality => { :allow_blank => true }

end
