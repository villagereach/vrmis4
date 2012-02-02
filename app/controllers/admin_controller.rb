class AdminController < ApplicationController
  layout 'admin'

  before_filter :authenticate

  helper_method :current_user


  def switch_user
    cookies[:switch_user] = true
    redirect_to admin_path
  end


  private

  def authenticate
    switch_user = cookies.delete(:switch_user)
    user = authenticate_or_request_with_http_basic('VRMIS3') do |username,password|
      password = nil if switch_user.present?
      password && User.find_by_username(username).try(:authenticate, password)
    end

    @current_user = user
  end

  def current_user
    @current_user
  end

end
