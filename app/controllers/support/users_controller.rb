class Support::UsersController < Support::BaseController
  def new
    @responsible_body = ResponsibleBody.find(params[:responsible_body_id])
    @user = @responsible_body.users.build
  end

  def create
    @user = CreateUserService.invite_responsible_body_user(
      user_params.merge(responsible_body_id: params[:responsible_body_id]),
    )
    # If anything goes wrong, the service will return a non-persisted user
    # object so that we can inspect the errors
    if @user.persisted?
      redirect_to return_path
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def return_path
    if params[:pilot] == 'devices'
      support_devices_responsible_body_path(@responsible_body)
    else
      support_internet_responsible_body_path(@responsible_body)
    end
  end

  def user_params
    params.require(:user).permit(
      :full_name,
      :email_address,
    )
  end
end
