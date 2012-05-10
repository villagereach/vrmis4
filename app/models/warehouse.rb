require "translatable"

class Warehouse < ActiveRecord::Base
  include Translatable

  belongs_to :province
  has_many :warehouse_visits, :primary_key => :code, :foreign_key => :warehouse_code, :order => :month

  before_validation { self.code = code.parameterize if code }

  validates :province, :presence => true
  validates :code, :presence => true, :uniqueness => true

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

  def as_json(options = nil)
    return super(options) unless (options||{})[:schema] == :offline

    {
      'code' => code,
    }
  end

end
