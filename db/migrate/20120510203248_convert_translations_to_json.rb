class ConvertTranslationsToJson < ActiveRecord::Migration
  def up
    Language.scoped.each do |lang|
      lang.translations = YAML.load(lang.translations_json)
      lang.save!
    end
  end

  def down
  end

end
