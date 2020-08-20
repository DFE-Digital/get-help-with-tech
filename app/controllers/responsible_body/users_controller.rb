class ResponsibleBody::UsersController < ResponsibleBody::BaseController
  def index
    @users = @responsible_body.users.order(:full_name)
  end

  def show; end

  def new
    @user = @responsible_body.users.build
  end

  def create
    @user = @responsible_body.users.new(
      user_params.merge(responsible_body_id: @responsible_body.id)
    )
    if @user.valid?
      @user.save!
      # TODO: schedule job to send invite email here
      redirect_to responsible_body_users_path
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
      :can_order_devices
    )
  end
end
