class IdealStockAmount < ActiveRecord::Base
  belongs_to :health_center
  belongs_to :package

end
