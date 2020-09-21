class School::UsersController < School::BaseController
  def index
    @users = @school.users.order(:full_name)
  end

  def new
    @user = @school.users.build
  end

  def create
    @user = CreateUserService.invite_school_user(user_params.merge(school_id: @school.id))
    if @user.persisted?
      redirect_to school_users_path
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(
      :full_name,
      :email_address,
      :telephone,
      :orders_devices,
    )
  end
end
