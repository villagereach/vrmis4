class Warehouse < ActiveRecord::Base
  belongs_to :province

  before_validation { self.code = code.parameterize if code }

  validates :province, :presence => true
  validates :code, :presence => true, :uniqueness => true

end
