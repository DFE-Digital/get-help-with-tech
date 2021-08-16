class ResponsibleBody::UsersController < ResponsibleBody::BaseController
  def index
    @users = @responsible_body.users.not_deleted.order(:full_name)
  end

  def show; end

  def new
    @rb_user = @responsible_body.users.not_deleted.build
  end

  def create
    authorize CreateUserService, policy_class: ResponsibleBody::BasePolicy

    @rb_user = CreateUserService.invite_responsible_body_user(
      user_params.merge(responsible_body_id: @responsible_body.id),
    )
    # If anything goes wrong, the service will return a non-persisted user
    # object so that we can inspect the errors
    if @rb_user.persisted?
      flash[:success] = I18n.t(:success, scope: %i[responsible_body users create], email_address: @rb_user.email_address)
      EventNotificationsService.broadcast(InviteEvent.new(user: @current_user))
      redirect_to responsible_body_users_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @rb_user = @responsible_body.users.not_deleted.find(params[:id])
  end

  def update
    @rb_user = @responsible_body.users.not_deleted.find(params[:id])

    authorize @rb_user, policy_class: ResponsibleBody::BasePolicy

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
end
