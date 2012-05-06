class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user


  def request_http_auth
    if request.xhr? && request.headers.include?('HTTP_AUTHORIZATION')
      render :json => 'AUTH_REQUIRED'.to_json, :status => 420
    else
      request_http_basic_authentication 'VRMIS4'
    end
  end

  def authenticate
    request_http_auth unless current_user
    @current_user
  end

  def current_user
    if !@current_user && request.headers.include?('HTTP_AUTHORIZATION')
      # no user, but auth tokens provided, try and load user
      @current_user = authenticate_with_http_basic do |username,password|
        User.find_by_username(username).try(:authenticate, password) || nil
      end
    end
    @current_user
  end

end
