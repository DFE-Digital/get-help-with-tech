class Support::Schools::UsersController < Support::BaseController
  before_action :set_school
  before_action { authorize User }

  def new
    @user = @school.users.build
  end

  def create
    user_attributes = @school.users.build(user_params).attributes.merge(school_id: @school.id).symbolize_keys!
    @user = CreateUserService.invite_school_user(user_attributes)

    if @user.persisted?
      redirect_to support_school_path(urn: @school.urn)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = present(policy_scope(@school.users).find(params[:id]))
  end

  def update
    @user = policy_scope(@school.users).find(params[:id])

    if @user.update(user_params)
      flash[:success] = 'User has been updated'
      redirect_to support_school_path(urn: @school.urn)
    else
      @user = present(@user)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = policy_scope(@school.users).find(params[:id])
    @user.update!(deleted_at: Time.zone.now)

    flash[:success] = 'User has been deleted'

    redirect_to support_school_path(@school)
  end

private

  def set_school
    @school = School.where_urn_or_ukprn(params[:school_urn]).first!
    authorize @school, :show?
  end

  def present(user)
    SchoolUserPresenter.new(user)
  end

  def user_params
    params.require(:user).permit(:full_name, :email_address, :telephone, :orders_devices)
  end
end
