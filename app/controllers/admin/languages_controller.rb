class Admin::LanguagesController < AdminController
  respond_to :html, :xml, :json

  def index
    @languages = Language.order(:locale)
    respond_with :admin, @languages
  end

  def show
    @language = Language.find(params[:id])
    respond_with :admin, @language
  end

end
