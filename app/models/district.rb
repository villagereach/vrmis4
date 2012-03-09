require "translatable"

class District < ActiveRecord::Base
  include Translatable

  belongs_to :delivery_zone
  has_many :health_centers, :dependent => :destroy

  before_validation { self.code = code.parameterize if code }

  validates :delivery_zone, :presence => true
  validates :code, :presence => true, :uniqueness => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

  def health_center_codes
    health_centers.map(&:code);
  end

end
