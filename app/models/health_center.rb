require "translatable"

class HealthCenter < ActiveRecord::Base
  include Translatable

  belongs_to :district
  has_many :ideal_stock_amounts, :include => :package, :order => 'packages.code', :dependent => :destroy

  accepts_nested_attributes_for :ideal_stock_amounts

  before_validation { self.code = code.parameterize if code }

  validates :code, :presence => true, :uniqueness => true
  validates :district, :presence => true
  validates :population, :numericality => { :allow_blank => true }
  validates :latitude, :numericality => { :allow_blank => true }
  validates :longitude, :numericality => { :allow_blank => true }


  alias_method :ideal_stock_amounts_orig, :ideal_stock_amounts
  def ideal_stock_amounts
    # builds any missing ideal stock amounts (i.e. due to a new package)
    (Package.all - ideal_stock_amounts_orig.map(&:package)).each do |package|
      ideal_stock_amounts_orig.build(:package => package)
    end

    # re-sort to include new packages
    ideal_stock_amounts_orig.sort_by {|a|a.package.code}
  end

end
