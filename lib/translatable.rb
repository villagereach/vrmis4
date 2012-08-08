module Translatable
  def self.included(base)
    base.instance_eval do
      define_attribute_method :translations
      after_save :save_translations, :if => :translations_changed?
    end
  end

  def t
    translations[Language.current_locale.to_s]
  end

  def translations
    @translations ||= Hash[Language.scoped.map do |lang|
      if self.code
        path = "#{self.class}.#{self.code}"
        [lang.locale.to_s, lang.t(path)]
      else
        [lang.locale.to_s, nil]
      end
    end]
    @translations.dup
  end

  def translations=(t)
    t.each do |locale,value|
      value = nil if value.blank?
      next if value == translations[locale.to_s]
      translations_will_change!
      (@changed_translations||=[]).push(locale.to_s)
    end
    @translations = t.dup
  end


  private

  def save_translations
    # could use self.changes but it doesn't track successive changes correctly
    @changed_translations.uniq.each do |locale|
      l = Language.find_by_locale(locale)
      l.translations[self.class.to_s] ||= {}
      if (value = @translations[locale]).present?
        l.translations[self.class.to_s][self.code] = value
      else
        # blank, delete it so it shows up as a missing translation
        l.translations[self.class.to_s].delete(self.code)
      end
      l.translations = l.translations
      l.save!
    end

    @changed_translations = nil
    true
  end

end
