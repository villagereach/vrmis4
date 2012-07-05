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
end
