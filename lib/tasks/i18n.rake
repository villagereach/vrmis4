LANG_FILES = Dir[Rails.root.join('db','i18n','*.yml')]

namespace :i18n do
  desc "Import YAML-based locale file into database"
  task :import, [:filename] => :environment do |t,args|
    YAML::load_file(args[:filename]).each do |locale,translations|
      l = Language.find_or_initialize_by_locale(locale)
      l.translations = translations
      l.save!
    end
  end

  task :export, [:locale] => :environment do |t,args|
    l = Language.find_by_locale(args[:locale])
    print Hash[l.locale, l.translations].to_yaml
  end

  task :upgrade => :environment do |t,args|
    LANG_FILES.each do |filename|
      YAML::load_file(filename).each do |locale,translations|
        unless l = Language.find_by_locale(locale)
          l = Language.new(:locale => locale, :name => locale.capitalize)
        end

        # adds new translations only (doesn't override existing)
        l.translations = translations.deep_merge!(l.translations)

        l.save!
      end
    end
  end

end
