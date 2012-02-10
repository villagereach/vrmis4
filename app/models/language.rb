class Language < ActiveRecord::Base
  serialize :translations, Hash

  validates :locale, :presence => true, :uniqueness => true
  validates :name, :presence => true

  default_scope order(:locale)


  def self.locales
    @locales ||= Language.select(:locale).map(&:locale)
  end
end
