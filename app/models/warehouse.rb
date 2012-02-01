class Warehouse < ActiveRecord::Base
  belongs_to :province

  before_validation { self.code = code && code.parameterize }

  validates :province, :presence => true
  validates :code, :presence => true, :uniqueness => true

end
