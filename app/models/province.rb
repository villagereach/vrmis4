require "translatable"

class Province < ActiveRecord::Base
  include Translatable

  has_many :delivery_zones, :dependent => :destroy
  has_many :districts, :through => :delivery_zones
  has_one :warehouse, :dependent => :destroy

  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }

end
