class WarehouseVisit < ActiveRecord::Base
  belongs_to :warehouse, :primary_key => :code, :foreign_key => :warehouse_code

  validates :province_code, :presence => true
  validates :month, :uniqueness => { :scope => :delivery_zone_code }

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

  def data
    @data ||= JSON.parse(self[:data]||"{}")
  end

  def data_json
    self[:data]
  end

  def data=(data)
    self.data_will_change!
    self[:data] = data.to_json
    @data = data
  end

end
