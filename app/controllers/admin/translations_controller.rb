class Admin::TranslationsController < AdminController
  
  def edit
    set_all_vars
    respond_to :html
  end
    
  def update
    set_all_vars

    #@by_ref will change @language.translations by reference
    if params[:translation].blank?
      @by_ref.delete(@keys.last)  #remove blanks
    else 
      @by_ref[@keys.last] = params[:translation].strip
    end

    # @language.translations_will_change! isn't working correctly right now
    @language.translations = @language.translations

    if @language.save
      flash[:notice] = "Translation updated for #{params[:key]}"
    else
      flash[:error] = "Language save error: #{@language.errors.full_messages.join(",")}"
    end
    redirect_to params[:return_to].present? ? params[:return_to] : [:admin, @language]
  end
    
  private 
  
  def set_all_vars
    @keys = params[:key].split(".")
    @language = Language.where(:locale=>@keys.first).first
    @by_ref = @language.translations
    for k in @keys[1..-2] do
      @by_ref[k] ||= {}   #will create new branches
      @by_ref = @by_ref[k]
    end
    @translation = @by_ref[@keys.last]
  end
end
