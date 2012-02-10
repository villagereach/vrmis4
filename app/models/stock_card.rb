require "translatable"

class StockCard < ActiveRecord::Base
  include Translatable

  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true

end
