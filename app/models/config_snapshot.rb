class ConfigSnapshot < ActiveRecord::Base
  serialize :provinces, Array
  serialize :health_centers, Array
  serialize :products, Array
  serialize :stock_cards, Array
  serialize :equipment_types, Array

  validates :month, :presence => true, :uniqueness => true


  def self.[](date)
    where(:month => date.to_date.beginning_of_month).first
  end

  def capture!
    self.provinces = capture_provinces
    self.health_centers = capture_health_centers
    self.products = capture_products
    self.stock_cards = capture_stock_cards
    self.equipment_types = capture_equipment_types
  end


  private

  def capture_provinces
    Province.order(:code).map do |province|
      { 'code'       => province.code,
        'population' => province.population,
        'latitude'   => province.latitude,
        'longitude'  => province.longitude,
        'delivery_zones' => province.delivery_zones.order(:code).map do |dz|
          { 'code'       => dz.code,
            'population' => dz.population,
            'latitude'   => dz.latitude,
            'longitude'  => dz.longitude,
            'districts'  => dz.districts.order(:code).map do |district|
              { 'code'           => district.code,
                'population'     => district.population,
                'latitude'       => district.latitude,
                'longitude'      => district.longitude,
                'health_centers' => district.health_centers.order(:code).map {|hc| hc.code}
              }
            end
          }
        end
      }
    end
  end

  def capture_health_centers
    HealthCenter.order(:code).map do |hc|
      { 'code'        => hc.code,
        'population'  => hc.population,
        'latitude'    => hc.latitude,
        'longitude'   => hc.longitude,
        'ideal_stock' => hc.ideal_stock_amounts.map do |isa|
          { 'package'  => isa.package.code,
            'quantity' => isa.quantity || 0,
          }
        end
      }
    end
  end

  def capture_products
    Product.order(:code).map do |product|
      { 'code'      => product.code,
        'type'      => product.product_type,
        'trackable' => product.trackable,
        'packages'  => product.packages.map do |package|
          { 'code'     => package.code,
            'quantity' => package.quantity,
            'primary'  => package.primary,
          }
        end
      }
    end
  end

  def capture_stock_cards
    StockCard.order(:code).map do |sc|
      { 'code' => sc.code }
    end
  end

  def capture_equipment_types
    EquipmentType.order(:code).map do |et|
      { 'code' => et.code }
    end
  end

end
