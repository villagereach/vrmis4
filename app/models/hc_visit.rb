class HcVisit < ActiveRecord::Base
  belongs_to :health_center, :primary_key => :code, :foreign_key => :health_center_code

  validates :province_code, :presence => true
  validates :month, :presence => true, :uniqueness => { :scope => :health_center_code }

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

  def as_json(options = nil)
    (options||{})[:schema] == :offline ? data : super(options)
  end

  def to_json(options = nil)
    (options||{})[:schema] == :offline ? data_json : super(options)
  end

end
