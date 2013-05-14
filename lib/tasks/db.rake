namespace :db do
  namespace :data do
    desc "Append contents of db/data.extension (defaults to yaml) into database"
    task :append => :environment do
      format_class = ENV['class'] || "YamlDb::Helper"
      helper = format_class.constantize
      SerializationHelper::Base.new(helper).load(db_dump_data_file(helper.extension), false)
    end

    desc "Append contents of db/data_dir into database"
    task :append_dir  => :environment do
      dir = ENV['dir'] || "base"
      format_class = ENV['class'] || "YamlDb::Helper"
      SerializationHelper::Base.new(format_class.constantize).load_from_dir(dump_dir("/#{dir}"), false)
    end
  end
  namespace :run_once do
    desc "2013-05-14:  Set up PCV translations"
    task :pcv_setup_5_14 => :environment do
      HealthCenter.transaction do
        en=Language.find_by_locale("en")
        ent=en.translations
        ent["reports"]["child_coverage"]["pcv"]="PCV"
        en.translations = ent
        en.save!
        
        pt=Language.find_by_locale("pt")
        ptt=pt.translations
        ptt["reports"]["child_coverage"]["pcv"]="PCV"
        pt.translations = ptt
        pt.save!
        
        pcv=Product.find_by_code('pcv')
        HealthCenter.all.each do |hc|
          q = hc.population*179/10000
          IdealStockAmount.create!(:health_center_id => hc.id, :product_id => pcv.id, :quantity=>q)
          puts "#{hc.id} #{hc.code} #{hc.population} #{q}"
        end
      end
    end
  end
        
          
end
