class Support::Devices::UsersController < Support::BaseController
  def new
    @school = School.find_by(urn: params[:school_urn])
    @user = @school.users.build
  end

  def create
    @school = School.find_by(urn: params[:school_urn])
    user_attributes = @school.users.build(user_params).attributes.merge(school_id: @school.id).symbolize_keys!
    @user = CreateUserService.invite_school_user(user_attributes)

    if @user.persisted?
      redirect_to support_devices_school_path(urn: @school.urn)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @school = School.find_by(urn: params[:school_urn])
    @user = present(@school.users.find(params[:id]))
  end

  def update
    @school = School.find_by(urn: params[:school_urn])
    @user = @school.users.find(params[:id])

    if @user.update(user_params)
      flash[:success] = 'User has been updated'
      redirect_to support_devices_school_path(urn: @school.urn)
    else
      @user = present(@user)
      render :edit, status: :unprocessable_entity
    end
  end

private

  def present(user)
    SchoolUserPresenter.new(user)
  end

  def user_params
    params.require(:user).permit(:full_name, :email_address, :telephone, :orders_devices)
  end
end
