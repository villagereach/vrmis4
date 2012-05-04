require "translatable"

class Product < ActiveRecord::Base
  include Translatable
  acts_as_list

  has_many :packages, :dependent => :destroy
  has_many :ideal_stock_amounts, :dependent => :destroy

  PRODUCT_TYPES = ['fuel', 'safety', 'syringe', 'test', 'vaccine']

  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true
  validates :product_type, :inclusion => PRODUCT_TYPES

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }


  def self.product_types
    PRODUCT_TYPES
  end

end
