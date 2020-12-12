class Support::ResponsibleBodies::UsersController < Support::BaseController
  before_action :set_responsible_body
  before_action { authorize User }

  def new
    @user = @responsible_body.users.build
  end

  def create
    @user = CreateUserService.invite_responsible_body_user(
      user_params.merge(responsible_body_id: params[:responsible_body_id]),
    )
    # If anything goes wrong, the service will return a  user
    # object so that we can inspect the errors
    if @user.errors.empty?
      redirect_to return_path
    else
      render :new, status: :unprocessable_entity
    end
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
    authorize @responsible_body, :show?
  end
end
