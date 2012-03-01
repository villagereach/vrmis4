class Language < ActiveRecord::Base
  serialize :translations, Hash

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
  
      
  def self.locales
    @locales ||= Language.select(:locale).map(&:locale)
  end
end
