# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120327200658) do

  create_table "config_snapshots", :force => true do |t|
    t.date     "month"
    t.text     "provinces"
    t.text     "health_centers"
    t.text     "products"
    t.text     "stock_cards"
    t.text     "equipment_types"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "config_snapshots", ["month"], :name => "index_config_snapshots_on_month"

  create_table "delivery_zones", :force => true do |t|
    t.integer  "province_id"
    t.string   "code"
    t.integer  "population"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delivery_zones", ["code"], :name => "index_delivery_zones_on_code"

  create_table "districts", :force => true do |t|
    t.integer  "delivery_zone_id"
    t.string   "code"
    t.integer  "population"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "districts", ["code"], :name => "index_districts_on_code"

  create_table "equipment_types", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "equipment_types", ["code"], :name => "index_equipment_types_on_code"

  create_table "hc_visits", :force => true do |t|
    t.string   "code"
    t.string   "province_code"
    t.string   "health_center_code"
    t.date     "month"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hc_visits", ["code"], :name => "index_hc_visits_on_code"
  add_index "hc_visits", ["health_center_code", "month"], :name => "index_hc_visits_on_health_center_code_and_month"
  add_index "hc_visits", ["month"], :name => "index_hc_visits_on_month"
  add_index "hc_visits", ["province_code", "month"], :name => "index_hc_visits_on_province_code_and_month"

  create_table "health_centers", :force => true do |t|
    t.integer  "district_id"
    t.string   "code"
    t.integer  "population"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "health_centers", ["code"], :name => "index_health_centers_on_code"

  create_table "ideal_stock_amounts", :force => true do |t|
    t.integer  "health_center_id"
    t.integer  "package_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ideal_stock_amounts", ["health_center_id"], :name => "index_ideal_stock_amounts_on_health_center_id"

  create_table "languages", :force => true do |t|
    t.string   "locale"
    t.string   "name"
    t.text     "translations"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "languages", ["locale"], :name => "index_languages_on_locale"

  create_table "packages", :force => true do |t|
    t.integer  "product_id"
    t.string   "code"
    t.integer  "quantity"
    t.boolean  "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "packages", ["code"], :name => "index_packages_on_code"

  create_table "products", :force => true do |t|
    t.integer  "product_type_id"
    t.string   "code"
    t.string   "product_type"
    t.boolean  "trackable",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "products", ["code"], :name => "index_products_on_code"

  create_table "provinces", :force => true do |t|
    t.string   "code"
    t.integer  "population"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provinces", ["code"], :name => "index_provinces_on_code"

  create_table "stock_cards", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "stock_cards", ["code"], :name => "index_stock_cards_on_code"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password_digest"
    t.string   "name"
    t.string   "language"
    t.string   "timezone"
    t.string   "role"
    t.datetime "last_login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "index_users_on_username"

  create_table "warehouses", :force => true do |t|
    t.integer  "province_id"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "warehouses", ["code"], :name => "index_warehouses_on_code"

end
