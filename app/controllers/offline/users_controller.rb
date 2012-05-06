class Offline::UsersController < OfflineController
  respond_to :json

  def current
    render :json => current_user.as_json(
      :only => [:username, :name, :role, :language, :timezone]
    )
  end

end
