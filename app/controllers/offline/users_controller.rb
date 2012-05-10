class Offline::UsersController < OfflineController
  respond_to :json

  def current
    render :json => current_user.as_json(:schema => :offline)
  end

end
