class ResponsibleBody::UsersController < ResponsibleBody::BaseController
  before_action :require_feature_flag!, only: %i[new create edit update]

  def index
    @users = @responsible_body.users.order(:full_name)
  end

  def show; end

  def new
    @rb_user = @responsible_body.users.build
  end

  def create
    @rb_user = @responsible_body.users.new(
      user_params.merge(responsible_body_id: @responsible_body.id),
    )
    if @rb_user.valid?
      @rb_user.save!
      # TODO: schedule job to send invite email here
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
      :can_order_devices,
    )
  end

  def require_feature_flag!
    render_404_if_feature_flag_inactive(:rbs_can_manage_users) unless %i[index show].include?(params[:action])
  end
end
