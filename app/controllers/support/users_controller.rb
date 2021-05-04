class Support::UsersController < Support::BaseController
  before_action :set_user, except: %i[new create search results]
  before_action { authorize User }

  def new
    set_school_if_present
    set_responsible_body_if_present

    deny_access_if_school_cannot_invite_users

    @form = Support::NewUserForm.new(
      school: @school,
      responsible_body: @responsible_body,
    )
    @user = User.new
    authorize @user
  end

  def create
    set_school_if_present
    set_responsible_body_if_present

    authorize User, :create?
    if @school
      @user = CreateUserService.invite_school_user(
        user_params.merge(school_id: @school.id),
      )
    elsif @responsible_body
      @user = CreateUserService.invite_responsible_body_user(
        user_params.merge(responsible_body_id: @responsible_body.id),
      )
    end

    if @user.persisted?
      redirect_to support_user_path(@user)
    else
      @form = Support::NewUserForm.new(
        school: @school,
        responsible_body: @responsible_body,
      )
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    @user = present(@user)
  end

  def update
    if @user.update(user_params)
      flash[:success] = 'User has been updated'
      redirect_to support_user_path(@user)
    else
      @user = present(@user)
      render :edit, status: :unprocessable_entity
    end
  end

  def search
    @search_form = Support::UserSearchForm.new
  end

  def results
    @search_form = Support::UserSearchForm.new(search_params.merge(scope: policy_scope(User)))
    @search_term = @search_form.email_address_or_full_name
    @results = @search_form.results
    @related_results = @search_form.related_results
    @maximum_search_result_number_reached = @search_form.maximum_search_result_number_reached?
  end

  def confirm_destroy; end

  def destroy
    @user.update!(deleted_at: Time.zone.now, orders_devices: false)

    flash[:success] = 'You have deleted this user'

    return_params = params.fetch(:user, {}).permit(:school_urn, :responsible_body_id)
    if return_params[:responsible_body_id]
      redirect_to support_responsible_body_path(return_params[:responsible_body_id])
    elsif return_params[:school_urn]
      redirect_to support_school_path(return_params[:school_urn])
    else
      redirect_to support_home_path
    end
  end

private

  # this is necessary to turn orders_devices=true/false into 0/1
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

  def search_params
    params.require(:support_user_search_form).permit(:email_address_or_full_name)
  end

  def set_user
    @user = User.not_deleted.find(params[:id])
    authorize @user
  end

  def set_school_if_present
    if params[:school_urn]
      @school = School.gias_status_open.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
      authorize @school, :show?
    end
  end

  def deny_access_if_school_cannot_invite_users
    if @school && !@school.can_invite_users?
      not_found
    end
  end

  def set_responsible_body_if_present
    if params[:responsible_body_id]
      @responsible_body = ResponsibleBody.gias_status_open.find(params[:responsible_body_id])
      authorize @responsible_body, :show?
    end
  end
end
