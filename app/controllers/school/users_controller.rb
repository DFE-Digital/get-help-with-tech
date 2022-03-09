class School::UsersController < School::BaseController
  def index
    @users = @school.users.not_deleted.order(:full_name)
  end

  def new
    @user = @school.users.build
    @change_order_devices = user_eligible_to_order_devices?
  end

  def create
    authorize User, policy_class: School::BasePolicy

    @user = CreateUserService.invite_school_user(user_params.merge(school_id: @school.id, orders_devices: true))

    if @user.persisted?
      redirect_to school_users_path(@school)
    else
      @user = present(@user)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = present(@school.users.not_deleted.find(params[:id]))
    @change_order_devices = user_eligible_to_order_devices?
  end

  def update
    @user = @school.users.not_deleted.find(params[:id])

    authorize @user, policy_class: School::BasePolicy

    if @user.update(user_eligible_to_order_devices? ? user_params.except('orders_devices') : user_params)
      flash[:success] = t(:success, scope: %w[school users])
      redirect_to school_users_path(@school)
    else
      @user = present(@user)
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_eligible_to_order_devices?
    SchoolPolicy.new(@user, @school).devices_orderable?
  end

  def present(user)
    SchoolUserPresenter.new(user)
  end

  def user_params
    params.require(:user).permit(
      :full_name,
      :email_address,
      :telephone,
      :orders_devices,
    )
  end
end
