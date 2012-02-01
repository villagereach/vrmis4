class Warehouse < ActiveRecord::Base
  belongs_to :province

  before_validation { self.code = code && code.parameterize }

  validates :code, :presence => true, :uniqueness => true
  validates :province, :presence => true

end
