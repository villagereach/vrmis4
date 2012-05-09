require "translatable"

class StockCard < ActiveRecord::Base
  include Translatable
  acts_as_list

  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

  def as_json(options = nil)
    return super(options) unless (options||{})[:schema] == :offline

    {
      'code'     => code,
      'position' => position,
    }
  end

end
