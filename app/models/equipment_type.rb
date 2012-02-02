class EquipmentType < ActiveRecord::Base
  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true

end
