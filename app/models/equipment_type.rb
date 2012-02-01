class EquipmentType < ActiveRecord::Base
  before_validation { self.code = code && code.parameterize }

  validates :code, :presence => true, :uniqueness => true

end
