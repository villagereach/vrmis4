class DeliveryZone < ActiveRecord::Base
  belongs_to :province
  has_many :districts, :dependent => :destroy

  before_validation { self.code = code && code.parameterize }

  validates :code, :presence => true, :uniqueness => true
  validates :province, :presence => true
  validates :population, :numericality => { :allow_blank => true }

end
