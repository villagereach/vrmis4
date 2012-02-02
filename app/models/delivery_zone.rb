class DeliveryZone < ActiveRecord::Base
  belongs_to :province
  has_many :districts, :dependent => :destroy

  before_validation { self.code = code.parameterize if code }

  validates :province, :presence => true
  validates :code, :presence => true, :uniqueness => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }

end
