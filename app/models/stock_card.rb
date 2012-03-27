require "translatable"

class StockCard < ActiveRecord::Base
  include Translatable

  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

end
