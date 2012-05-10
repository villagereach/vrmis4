require "translatable"

class DeliveryZone < ActiveRecord::Base
  include Translatable

  belongs_to :province
  has_many :districts, :dependent => :destroy

  before_validation { self.code = code.parameterize if code }

  validates :province, :presence => true
  validates :code, :presence => true, :uniqueness => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }

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
