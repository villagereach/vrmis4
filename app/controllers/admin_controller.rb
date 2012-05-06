class AdminController < ApplicationController
  layout 'admin'

  before_filter :authenticate, :except => :switch_user

  helper_method :current_user


  def switch_user
    render :layout => 'application'
  end


  private

  def authenticate
    @current_user = authenticate_with_http_basic do |username,password|
      User.find_by_username(username).try(:authenticate, password) || nil
    end

    request_http_basic_authentication 'VRMIS4' unless @current_user
  end

  def current_user
    @current_user
  end

end
