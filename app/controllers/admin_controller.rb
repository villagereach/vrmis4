class AdminController < ApplicationController
  layout 'admin'

  before_filter :require_admin, :except => :login


  def login
    render :layout => 'application'
  end

  def require_admin
    request_http_auth unless authenticate.try(:role) == 'admin'
  end

end
