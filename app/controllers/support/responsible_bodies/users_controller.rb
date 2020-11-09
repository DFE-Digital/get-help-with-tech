class Support::ResponsibleBodies::UsersController < Support::BaseController
  before_action :set_responsible_body

  def new
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

  def edit
    @user = @responsible_body.users.find(params[:id])
  end

  def update
    @user = @responsible_body.users.find(params[:id])

    if @user.update(user_params)
      flash[:success] = 'User has been updated'
      redirect_to return_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = @responsible_body.users.find(params[:id])
    @user.update!(deleted_at: Time.zone.now)

    flash[:success] = 'User has been deleted'

    redirect_to return_path
  end

private

  def return_path
    support_responsible_body_path(@responsible_body)
  end

  def user_params
    params.require(:user).permit(
      :full_name,
      :email_address,
      :telephone,
    )
  end

  def set_responsible_body
    @responsible_body = ResponsibleBody.find(params[:responsible_body_id])
  end
end
