#encoding: utf-8
class Language < ActiveRecord::Base
  validates :locale, :presence => true, :uniqueness => true
  validates :name, :presence => true

  default_scope order(:locale)

  #console find-a-translation
  def pgrep(pat)
    translations.each{|k,v| rgrep(pat,k,v,nil) }
    nil
  end

  def rgrep(pat,key,val,prefix)
    newkey = [prefix,key].compact.join(".")
    if val.is_a? Hash
      val.each {|k,v| rgrep(pat,k,v, newkey)}
    else
      puts "#{newkey}: #{val}" if val.to_s.match(pat)
    end
  end

  def self.current_locale
    I18n.locale
  end

  def translate(path = nil)
    path.to_s.split('.').inject(translations) do |hash,key|
      hash = hash ? hash[key] : nil
    end
  end

  alias_method :t, :translate

  def self.locales
    @locales ||= Language.select(:locale).map(&:locale)
  end

  def translations
    @translations ||= JSON.parse(self[:translations]||"{}")
  end

  def translations_json
    self[:translations]
  end

  def translations=(translations)
    self[:translations] = translations.to_json
    @translations = translations
  end

  def as_json(options = nil)
    (options||{})[:schema] == :offline ? data : super(options)
  end

  def to_json(options = nil)
    (options||{})[:schema] == :offline ? data_json : super(options)
  end

end
