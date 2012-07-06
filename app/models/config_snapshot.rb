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


  def json_schema
    {} \
      .deep_merge!(core_schema) \
      .deep_merge!(refrigerators_schema) \
      .deep_merge!(epi_inventory_schema) \
      .deep_merge!(rdt_inventory_schema) \
      .deep_merge!(equipment_status_schema) \
      .deep_merge!(stock_cards_schema) \
      .deep_merge!(rdt_stock_schema) \
      .deep_merge!(epi_stock_schema) \
      .deep_merge!(full_vac_tally_schema) \
      .deep_merge!(child_vac_tally_schema) \
      .deep_merge!(adult_vac_tally_schema) \
      .deep_merge!(observations_schema)
  end


  private

  def core_schema
    # TODO:
    # - other_non_visit should be required if non_visi_reason is 'other'
    # - other_non_visit shouldn't exist if non_visit_reason is not 'other'
    {
      '$schema' => 'http://json-schema.org/draft-03/schema#',
      'description' => 'Health Center Visit',
      'type' => [
        { 'description' => 'Health Center Visit (visited)',
          'type' => 'object',
          'properties' => {
            'code' => { 'type' => 'string', 'required' => true, 'pattern' => '^[\w-]+-\d{4}-\d{2}$' },
            'district_code' => { 'type' => 'string', 'required' => true, 'pattern' => '^[\w-]+$' },
            'delivery_zone_code' => { 'type' => 'string', 'required' => true, 'pattern' => '^[\w-]+$' },
            'health_center_code' => { 'type' => 'string', 'required' => true, 'pattern' => '^[\w-]+$' },
            'month' => { 'type' => 'string', 'required' => true, 'pattern' => '^\d{4}-\d{2}$' },
            'last_visited' => { 'type' => 'string', 'pattern' => '^\d{4}-\d{2}-\d{2}$' },
            'visited' => { 'type' => 'boolean', 'required' => true, 'enum' => [true] },
            'visited_at' => { 'type' => 'string', 'required' => true, 'pattern' => '^\d{4}-\d{2}-\d{2}$' },
            'vehicle_id' => { 'type' => 'string', 'pattern' => '^.+$' },
            'notes' => { 'type' => 'string' },

            'non_visit_reason' => { 'type' => 'null' },
            'other_non_visit_reason' => { 'type' => 'null' },

            'refrigerators' => { '$ref' => '#/refrigerators' },
            'epi_inventory' => { '$ref' => '#/epi_inventory' },
            'rdt_inventory' => { '$ref' => '#/rdt_inventory' },
            'equipment_status' => { '$ref' => '#/equipment_status' },
            'stock_cards' => { '$ref' => '#/stock_cards' },
            'rdt_stock' => { '$ref' => '#/rdt_stock' },
            'epi_stock' => { '$ref' => '#/epi_stock' },
            'full_vac_tally' => { '$ref' => '#/full_vac_tally' },
            'child_vac_tally' => { '$ref' => '#/child_vac_tally' },
            'adult_vac_tally' => { '$ref' => '#/adult_vac_tally' },
            'observations' => { '$ref' => '#/observations' },
          },
          'additionalProperties' => false,
        },
        { 'description' => 'Health Center Visit (visited)',
          'type' => 'object',
          'properties' => {
            'code' => { 'type' => 'string', 'required' => true, 'pattern' => '^[\w-]+-\d{4}-\d{2}$' },
            'district_code' => { 'type' => 'string', 'required' => true, 'pattern' => '^[\w-]+$' },
            'delivery_zone_code' => { 'type' => 'string', 'required' => true, 'pattern' => '^[\w-]+$' },
            'health_center_code' => { 'type' => 'string', 'required' => true, 'pattern' => '^[\w-]+$' },
            'month' => { 'type' => 'string', 'required' => true, 'pattern' => '^\d{4}-\d{2}$' },
            'last_visited' => { 'type' => 'string', 'pattern' => '^\d{4}-\d{2}-\d{2}$' },
            'visited' => { 'type' => 'boolean', 'required' => true, 'enum' => [false] },
            'non_visit_reason' => { 'type' => 'string', 'required' => true, 'enum' => ['road_problem', 'vehicle_problem', 'health_center_closed', 'other'] },
            'other_non_visit_reason' => { 'type' => 'string', 'pattern' => '^.+$' },
            'notes' => { 'type' => 'string' },

            'visited_at' => { 'type' => 'null' },
            'vehicle_id' => { 'type' => 'null' },

            'refrigerators' => { 'type' => 'null' },
            'epi_inventory' => { 'type' => 'null' },
            'rdt_inventory' => { 'type' => 'null' },
            'equipment_status' => { 'type' => 'null' },
            'stock_cards' => { 'type' => 'null' },
            'rdt_stock' => { '$ref' => '#/rdt_stock' },
            'epi_stock' => { '$ref' => '#/epi_stock' },
            'full_vac_tally' => { '$ref' => '#/full_vac_tally' },
            'child_vac_tally' => { '$ref' => '#/child_vac_tally' },
            'adult_vac_tally' => { '$ref' => '#/adult_vac_tally' },
            'observations' => { '$ref' => '#/observations' },
          },
          'additionalProperties' => false,
        },
      ],

      'req_yes_no_nr' => {
        'type' => 'string',
        'required' => true,
        'enum' => ['yes', 'no', 'NR'],
      },
      'req_integer' => {
        'type' => 'integer',
        'required' => true,
        'minimum' => 0,
      },
      'req_integer_w_nr' => {
        'type' => [
          { 'type' => 'integer', 'required' => true, 'minimum' => 0 },
          { 'type' => 'string', 'required' => true, 'enum' => ['NR'] },
        ],
      },
    }
  end

  def req_yes_no_nr
    # would prefer reference but error messages are impossible to trace
    # { '$ref' => '#/req_yes_no_nr' }

    {
      'type' => 'string',
      'required' => true,
      'enum' => ['yes', 'no', 'NR'],
    }
  end

  def req_integer
    # would prefer reference but error messages are impossible to trace
    # { '$ref' => '#/req_integer' }

    {
      'type' => 'integer',
      'required' => true,
      'minimum' => 0,
    }
  end

  def req_integer_w_nr
    # would prefer reference but error messages are impossible to trace
    # { '$ref' => '#/req_integer_w_nr' }

    {
      'type' => ['integer', 'string'],
      'required' => true,
      'minimum' => 0,
      'pattern' => '^NR$',
    }
  end

  def refrigerators_schema
    # TODO:
    # - running_problems should be required if running is 'no'
    # - running_problems shouldn't exist if running isn't 'no'
    # - other_running_problem should be required if running_problems include 'OTHER'
    # - other_running_problem shouldn't exist if running_problems doesn't include 'OTHER'
    {
      'refrigerators' => {
        'type' => 'array',
        'items' => {
          'properties' => {
            'code' => { 'type' => 'string', 'required' => true, 'pattern' => '^.+$' },
            'past_problem' => { 'type' => 'string', 'required' => true, 'enum' => ['yes', 'no', 'unknown'] },
            'temperature' => { 'type' => ['number', 'null'] },
            'running' => { 'type' => 'string', 'required' => true, 'enum' => ['yes', 'no', 'unknown'] },
            'running_problems' => {
              'type' => ['array', 'null'],
              'uniqueItems' => true,
              'items' => {
                'type' => 'string',
                'enum' => ['OPER', 'BURN', 'GAS', 'FAULT', 'THERM', 'OTHER']
              },
              'minItems' => 1,
            },
            'other_running_problem' => { 'type' => ['string', 'null'] },
          },
          'additionalProperties' => false,
        },
        'additionalItems' => false,
      },
    }
  end

  def epi_inventory_schema
    epi_types = ['vaccine', 'syringe', 'safety', 'fuel']
    products = Hash[data['products'].map {|p| [p['code'], p] }]
    pkg_types = Hash[data['packages'].map {|p| [p['code'], products[p['product_code']]['product_type']] }]
    epi_pkgs = data['packages'].select {|p| epi_types.include?(pkg_types[p['code']]) }

    properties = epi_pkgs.inject({}) do |hash,pkg|
      hash[pkg['code']] = {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'existing' => req_integer_w_nr,
          'delivered' => req_integer,
        },
        'additionalProperties' => false,
      }

      if pkg_types[pkg['code']] == 'vaccine'
        hash[pkg['code']]['properties']['spoiled'] = req_integer_w_nr
      end

      hash
    end

    {
      'epi_inventory' => {
        'type' => 'object',
        'required' => true,
        'properties' => properties,
        'additionalProperties' => false,
      },
    }
  end

  def rdt_inventory_schema
    rdt_products = data['products'].select {|p| p['product_type'] == 'test' }
    rdt_prod_codes = rdt_products.map {|p| p['code'] }
    rdt_pkgs = data['packages'].select {|p| rdt_prod_codes.include?(p['product_code']) }

    properties = rdt_pkgs.inject({}) do |hash,pkg|
      hash[pkg['code']] = {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'usage_prev_month' => req_integer_w_nr,
          'ideal_stock' => req_integer_w_nr,
          'existing' => req_integer_w_nr,
          'distributed' => req_integer,
        },
        'additionalProperties' => false,
      }
      hash
    end

    {
      'rdt_inventory' => {
        'type' => 'object',
        'required' => true,
        'properties' => properties,
        'additionalProperties' => false,
      },
    }
  end

  def equipment_status_schema
    properties = {
      'notes' => { 'type' => ['string', 'null'] }
    }

    data['equipment_types'].map do |et|
      properties[et['code']] = {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'present' => req_yes_no_nr,
          'working' => req_yes_no_nr,
        },
        'additionalProperties' => false,
      }
    end

    {
      'equipment_status' => {
        'type' => 'object',
        'required' => true,
        'properties' => properties,
        'additionalProperties' => false,
      },
    }
  end

  def stock_cards_schema
    properties = data['stock_cards'].inject({}) do |hash,sc|
      hash[sc['code']] = {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'present' => req_yes_no_nr,
          'used_correctly' => req_yes_no_nr,
        },
        'additionalProperties' => false,
      }
      hash
    end

    {
      'stock_cards' => {
        'type' => 'object',
        'required' => true,
        'properties' => properties,
        'additionalProperties' => false,
      },
    }
  end

  def rdt_stock_schema
    rdt_products = data['products'].select {|p| p['product_type'] == 'test' }

    properties = rdt_products.inject({}) do |hash,prod|
      hash[prod['code']] = {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'total' => req_integer_w_nr,
          'positive' => req_integer_w_nr,
          'indeterminate' => req_integer_w_nr,
        },
        'additionalProperties' => false,
      }
      hash
    end

    {
      'rdt_stock' => {
        'type' => 'object',
        'required' => true,
        'properties' => properties,
        'additionalProperties' => false,
      },
    }
  end

  def epi_stock_schema
    epi_products = data['products'].select {|p| p['product_type'] == 'vaccine' }

    properties = epi_products.inject({}) do |hash,prod|
      hash[prod['code']] = {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'first_of_month' => req_integer_w_nr,
          'received' => req_integer_w_nr,
          'distributed' => req_integer_w_nr,
          'loss' => req_integer_w_nr,
          'end_of_month' => req_integer_w_nr,
          'expiration' => { 'type' => 'string', 'required' => true, 'pattern' => '^(\d{4}-\d{2}|NR)$' },
        },
        'additionalProperties' => false,
      }
      hash
    end

    {
      'epi_stock' => {
        'type' => 'object',
        'required' => true,
        'properties' => properties,
        'additionalProperties' => false,
      },
    }
  end

  def full_vac_tally_schema
    {
      'full_vac_tally' => {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'female' => {
            'type' => 'object',
            'required' => true,
            'properties' => {
              'hc' => req_integer_w_nr,
              'mb' => req_integer_w_nr,
            },
            'additionalProperties' => false,
          },
          'male' => {
            'type' => 'object',
            'required' => true,
            'properties' => {
              'hc' => req_integer_w_nr,
              'mb' => req_integer_w_nr,
            },
            'additionalProperties' => false,
          },
        },
        'additionalProperties' => false,
      },
    }
  end

  def child_vac_tally_schema
    vaccinations = [
      'bcg', 'polio0', 'polio1', 'polio2', 'polio3',
      'penta1', 'penta2', 'penta3', 'measles',
    ]

    properties = vaccinations.inject({}) do |hash,dose|
      hash[dose] = {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'hc0_11' => req_integer_w_nr,
          'mb0_11' => req_integer_w_nr,
          'hc12_23' => req_integer_w_nr,
          'mb12_23' => req_integer_w_nr,
        },
        'additionalProperties' => false,
      }

      if dose == 'polio0'
        # newborns can't get doses at 12-23 months
        hash[dose]['properties'].delete('hc12_23')
        hash[dose]['properties'].delete('mb12_23')
      end

      hash
    end

    # opened vials counts
    ['bcg', 'polio10', 'penta1', 'measles'].each do |pkg|
      properties[pkg] ||= {
        'type' => 'object',
        'required' => true,
        'properties' => {},
        'additionalProperties' => false,
      }
      properties[pkg]['properties']['opened'] = req_integer_w_nr
    end

    {
      'child_vac_tally' => {
        'type' => 'object',
        'required' => true,
        'properties' => properties,
        'additionalProperties' => false,
      },
    }
  end

  def adult_vac_tally_schema
    # FIXME: migration data is bleeding extra data (opened vial counts from child) into this structure
    groups = [
      'w_pregnant', 'w_15_49_community', 'w_15_49_student', 'w_15_49_labor',
      'student', 'labor', 'other',
    ]

    properties = groups.inject({}) do |hash,group|
      hash[group] = {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'tet1hc' => req_integer_w_nr,
          'tet1mb' => req_integer_w_nr,
          'tet2_5hc' => req_integer_w_nr,
          'tet2_5mb' => req_integer_w_nr,
        },
        'additionalProperties' => false,
      }

      if group =~ /(?:student|labor)$/
        # students and worker vaccination groups aren't kept for health centers
        hash[group]['properties'].delete('tet1hc')
        hash[group]['properties'].delete('tet2_5hc')
      end

      hash
    end

    properties['tetanus'] = {
      'type' => 'object',
      'required' => true,
      'properties' => {
        'opened' => req_integer_w_nr,
      },
      'additionalProperties' => false,
    }

    {
      'adult_vac_tally' => {
        'type' => 'object',
        'required' => true,
        'properties' => properties,
        'additionalProperties' => false,
      },
    }
  end

  def observations_schema
    {
      'observations' => {
        'type' => 'object',
        'required' => true,
        'properties' => {
          'verified_by' => { 'type' => 'string', 'required' => true, 'pattern' => '^.+$' },
          'verified_by_title' => { 'type' => 'string', 'required' => true, 'pattern' => '^.+$' },
          'confirmed_by' => { 'type' => 'string', 'required' => true, 'pattern' => '^.+$' },
          'confirmed_by_title' => { 'type' => 'string', 'required' => true, 'pattern' => '^.+$' },
        },
        'additionalProperties' => false,
      },
    }
  end

  def to_month(value)
    return nil if value.nil?
    value += '-01' if value =~ /^\d{4}-\d{1,2}$/
    value.to_date.beginning_of_month
  end

end
