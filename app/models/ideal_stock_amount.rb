class IdealStockAmount < ActiveRecord::Base
  belongs_to :health_center
  belongs_to :package

  validates :health_center, :presence => true
  validates :package, :presence => true
  validates :package_id, :uniqueness => { :scope => :health_center_id }
  validates :quantity, :numericality => true

  def package_code
    package.code
  end

end
