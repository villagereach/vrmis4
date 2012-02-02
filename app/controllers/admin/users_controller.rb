class Admin::UsersController < AdminController
  respond_to :html, :xml, :json

  def index
    @users = User.order(:username).page(params[:page])
    respond_with :admin, @users
  end

  def show
    @user = User.find(params[:id])
    respond_with :admin, @user
  end

  def new
    @user = User.new
    respond_with :admin, @user
  end

  def edit
    @user = User.find(params[:id])
    respond_with :admin, @user
  end

  def create
    @user = User.new
    @user.attributes = params[:user]
    if @user.save
      flash[:notice] = "User created successfully."
    end

    respond_with :admin, @user
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated successfully."
    end

    respond_with :admin, @user
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:notice] = "User destroyed successfully."
    end

    respond_with :admin, @user
  end

end
