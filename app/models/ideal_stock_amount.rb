class IdealStockAmount < ActiveRecord::Base
  belongs_to :health_center
  belongs_to :package

  validates :health_center, :presence => true
  validates :package, :presence => true
  validates :quantity, :numericality => { :allow_blank => true }

end
