class School::UsersController < School::BaseController
  def index
    @users = @school.users.order(:full_name)
  end

  def new
    @user = @school.users.build
  end

  def create
    @user = @school.users.new(user_params)
    if @user.valid?
      @user.save!
      InviteSchoolUserMailer.with(user: @user).nominated_contact_email.deliver_later
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
