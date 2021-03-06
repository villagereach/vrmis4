require "translatable"

class Package < ActiveRecord::Base
  include Translatable
  acts_as_list

  belongs_to :product

  before_validation { self.code = code.parameterize if code }
  after_save :steal_primary, :if => :primary?

  validates :product, :presence => true
  validates :code, :presence => true, :uniqueness => true
  validates :quantity, :numericality => true
  validates :primary, :acceptance => {
    :accept => true, :message => "must be selected",
    :if => lambda { product.packages.reject{|p| p.id==id }.none?(&:primary?) }
  }

  scope :primary, where(:primary => true)
  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }


  def as_json(options = nil)
    return super(options) unless (options||{})[:schema] == :offline

    {
      'code'         => code,
      'position'     => position,
      'quantity'     => quantity,
      'primary'      => primary,
      'product_code' => product.code,
    }
  end

  private

  def steal_primary
    # make sure we're the only product package w/ a primary flag set
    others = product.packages.select {|p| p.primary? && p.id != id}
    others.each {|p| p.update_attribute(:primary, false) }
  end

end
