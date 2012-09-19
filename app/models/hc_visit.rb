class HcVisit < ActiveRecord::Base
  belongs_to :health_center, :primary_key => :code, :foreign_key => :health_center_code

  after_save :update_last_visited

  validates :province_code, :presence => true
  validates :month, :presence => true, :uniqueness => { :scope => :health_center_code }

  scope :updated_since, ->(datetime) {
    datetime ? where("#{table_name}.updated_at > ?", datetime) : scoped
  }

  scope :visited, where('visited_at IS NOT NULL')


  def data
    @data ||= JSON.parse(self[:data]||"{}")
  end

  def data_json
    self[:data]
  end

  def data=(data)
    self.month = data['month'] + '-01'
    self.health_center_code = data['health_center_code']
    self.province_code = DeliveryZone.find_by_code(data['delivery_zone_code']).province.code

    self.visited_at = data['visited'] ? data['visited_at'] : nil

    # replace last_visited value w/ a fresh version
    prev = health_center.hc_visits.visited.where('month < ?', month).last
    data['last_visited'] = prev ? prev.visited_at.try(:strftime, '%Y-%m-%d') : nil

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


  private

  def update_last_visited
    # handles case where visited status changed from visited to not visited
    last_visited = data['visited'] ? data['visited_at'] : data['last_visited']

    # replace last_visited attribute for all future visits that were either
    # not visited or is the next visit since this one
    health_center.hc_visits.where('month > ?', month).each do |hcv|
      hcv.data_will_change!
      hcv.data = hcv.data.merge('last_visited' => last_visited)
      hcv.save!

      break if hcv.visited_at
    end
  end

end
