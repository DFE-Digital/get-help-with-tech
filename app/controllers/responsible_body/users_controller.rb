class ResponsibleBody::UsersController < ResponsibleBody::BaseController
  before_action :require_feature_flag!, only: %i[edit update]

  def index
    @users = @responsible_body.users.order(:full_name)
  end

  def show; end

  def new
    @rb_user = @responsible_body.users.build
  end

  def create
    @rb_user = CreateUserService.invite_responsible_body_user(
      user_params.merge(responsible_body_id: @responsible_body.id),
    )
    # If anything goes wrong, the service will return a non-persisted user
    # object so that we can inspect the errors
    if @rb_user.persisted?
      flash[:success] = I18n.t(:success, scope: %i[responsible_body users create], email_address: @rb_user.email_address)
      EventNotificationsService.broadcast(InviteEvent.new(user: @user))
      redirect_to responsible_body_users_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @rb_user = @responsible_body.users.find(params[:id])
  end

  def update
    @rb_user = @responsible_body.users.find(params[:id])
    if @rb_user.update(user_params)
      redirect_to responsible_body_users_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(
      :full_name,
      :email_address,
      :telephone,
    )
  end

  def require_feature_flag!
    render_404_if_feature_flag_inactive(:rbs_can_manage_users)
  end
end
