class ConfigSnapshot < ActiveRecord::Base
  belongs_to :province, :primary_key => :code, :foreign_key => :province_code

  validates :province_code, :presence => true
  validates :month, :uniqueness => { :scope => :province_code }

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

  scope :for_date, ->(date) {
    where('month IS NOT NULL AND month <= ?', date).order(:month).limit(1)
  }


  def month=(date)
    if (month = to_month(date)) != self.month
      self[:month] = month
      self.data_will_change!
      self.data['month'] = month ? month.strftime('%Y-%m') : nil
    end
  end

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

  def as_json(options = nil)
    (options||{})[:schema] == :offline ? data : super(options)
  end

  def to_json(options = nil)
    (options||{})[:schema] == :offline ? data_json : super(options)
  end

  def capture!
    delivery_zones = province.delivery_zones
    districts = delivery_zones.map {|dz| dz.districts}.flatten
    health_centers = districts.map {|d| d.health_centers}.flatten

    self.data = {
      'month'           => month && month.strftime('%Y-%m'),
      'delivery_zones'  => delivery_zones.as_json(:schema => :offline),
      'districts'       => districts.as_json(:schema => :offline),
      'health_centers'  => health_centers.as_json(:schema => :offline),
      'warehouses'      => [province.warehouse.as_json(:schema => :offline)],
      'products'        => Product.scoped.as_json(:schema => :offline),
      'packages'        => Package.scoped.as_json(:schema => :offline),
      'equipment_types' => EquipmentType.scoped.as_json(:schema => :offline),
      'stock_cards'     => StockCard.scoped.as_json(:schema => :offline),
    }
  end

  def latest_updated_at
    delivery_zones = province.delivery_zones
    districts = delivery_zones.map {|dz| dz.districts}.flatten
    health_centers = districts.map {|d| d.health_centers}.flatten

    [
      province.updated_at,
      province.warehouse.updated_at,
      delivery_zones.map(&:updated_at).compact.max,
      districts.map(&:updated_at).compact.max,
      health_centers.map(&:updated_at).compact.max,
      Product.order(:updated_at).last.updated_at,
      Package.order(:updated_at).last.updated_at,
      StockCard.order(:updated_at).last.updated_at,
      EquipmentType.order(:updated_at).last.updated_at,
    ].compact.max
  end


  private

  def to_month(value)
    return nil if value.nil?
    value += '-01' if value =~ /^\d{4}-\d{1,2}$/
    value.to_date.beginning_of_month
  end

end
