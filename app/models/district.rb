class District < ActiveRecord::Base
  belongs_to :delivery_zone
  has_many :health_centers

end
