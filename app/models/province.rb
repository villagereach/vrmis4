require "translatable"

class Province < ActiveRecord::Base
  include Translatable

  has_many :delivery_zones, :dependent => :destroy
  has_many :districts, :through => :delivery_zones
  has_many :health_centers, :through => :districts
  has_many :hc_visits, :through => :health_centers
  has_one  :warehouse, :dependent => :destroy
  has_many :warehouse_visits, :through => :warehouse
  has_many :config_snapshots, :primary_key => :code, :foreign_key => :province_code, :order => :month

  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

end
