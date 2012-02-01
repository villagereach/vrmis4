class HealthCenter < ActiveRecord::Base
  belongs_to :district
  has_many :ideal_stock_amounts

end
