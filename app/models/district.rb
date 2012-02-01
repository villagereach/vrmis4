class District < ActiveRecord::Base
  belongs_to :delivery_zone
  has_many :health_centers, :dependent => :destroy

  before_validation { self.code = code && code.parameterize }

  validates :delivery_zone, :presence => true
  validates :code, :presence => true, :uniqueness => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }

end
