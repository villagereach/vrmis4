require "translatable"

class Warehouse < ActiveRecord::Base
  include Translatable

  belongs_to :province

  before_validation { self.code = code.parameterize if code }

  validates :province, :presence => true
  validates :code, :presence => true, :uniqueness => true

end
