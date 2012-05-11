class Offline::TranslationsController < OfflineController
  respond_to :js

  def index
    @languages = Language.scoped

    render :js => <<-JAVASCRIPT
      var I18n = I18n || {};
      I18n.locale = #{I18n.locale.to_json};
      I18n.defaultLocale = #{I18n.default_locale.to_json};
      I18n.translations = {#{@languages.map{|l| "#{l.locale.to_json}:#{l.translations_json}"}.join(',')}};
    JAVASCRIPT
  end
end
