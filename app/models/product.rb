require "translatable"

class Product < ActiveRecord::Base
  include Translatable
  acts_as_list

  has_many :packages, :dependent => :destroy
  has_many :ideal_stock_amounts, :dependent => :destroy

  PRODUCT_TYPES = ['fuel', 'safety', 'syringe', 'test', 'vaccine']
  ISA_TYPES = ['safety', 'syringe', 'vaccine']

  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true
  validates :product_type, :inclusion => PRODUCT_TYPES

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

  scope :has_isa, where(:product_type => ISA_TYPES)


  def self.product_types
    PRODUCT_TYPES
  end

  def self.isa_calcs
    Hash[has_isa.select(&:isa_calc).map {|p| [ p.code, p.isa_calc ] }].symbolize_keys!
  end

  def has_isa?
    ISA_TYPES.include?(product_type)
  end

  def as_json(options = nil)
    return super(options) unless (options||{})[:schema] == :offline

    {
      'code'         => code,
      'position'     => position,
      'product_type' => product_type,
      'trackable'    => trackable,
    }
  end

end
