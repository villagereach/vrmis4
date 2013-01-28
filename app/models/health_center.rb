require "translatable"

class HealthCenter < ActiveRecord::Base
  include Translatable

  belongs_to :district
  has_many :ideal_stock_amounts, :include => :product, :order => 'products.code'
  has_many :hc_visits, :primary_key => :code, :foreign_key => :health_center_code, :order => :month

  accepts_nested_attributes_for :ideal_stock_amounts

  before_validation { self.code = code.parameterize if code }
  before_destroy :destroy_ideal_stock_amounts

  validates :code, :presence => true, :uniqueness => true
  validates :district, :presence => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }


  alias_method :ideal_stock_amounts_orig, :ideal_stock_amounts
  def ideal_stock_amounts
    # builds any missing ideal stock amounts (i.e. due to a new product)
    (Product.has_isa - ideal_stock_amounts_orig.map(&:product)).each do |product|
      ideal_stock_amounts_orig.build(:product => product)
    end

    # re-sort to include new products
    ideal_stock_amounts_orig.sort_by {|a|a.product.code}
  end

  def as_json(options = nil)
    return super(options) unless (options||{})[:schema] == :offline

    {
      'code'                => code,
      'population'          => population,
      'district_code'       => district.code,
      'delivery_zone_code'  => district.delivery_zone.code,
      'ideal_stock_amounts' => Hash[
        ideal_stock_amounts.map {|isa| [isa.product_code, isa.quantity] }
      ],
    }
  end


  private

  def destroy_ideal_stock_amounts
    ideal_stock_amounts.each(&:destroy)
  end

end
