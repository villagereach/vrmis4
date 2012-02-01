class HealthCenter < ActiveRecord::Base
  belongs_to :district
  has_many :ideal_stock_amounts, :dependent => :destroy

  before_validation { self.code = code && code.parameterize }

  validates :code, :presence => true, :uniqueness => true
  validates :district, :presence => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }

end
