class Province < ActiveRecord::Base
  has_many :delivery_zones
  has_many :districts, :through => :delivery_zones
  has_one :warehouse

end
