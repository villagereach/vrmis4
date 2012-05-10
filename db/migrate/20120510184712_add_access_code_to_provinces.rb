class AddAccessCodeToProvinces < ActiveRecord::Migration
  ACCESS_CODES = {
    'nampula'      => 'vacina',
    'niassa'       => 'seringa',
    'cabo-delgado' => 'geleira',
    'maputo'       => 'aldeia',
    'gaza'         => 'medicina',

  }

  def change
    add_column :provinces, :access_code, :string

    Province.scoped.each do |province|
      province.update_attributes(:access_code => ACCESS_CODES[province.code])
    end
  end
end
