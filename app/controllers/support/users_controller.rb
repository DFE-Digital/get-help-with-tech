class Support::UsersController < Support::BaseController
  before_action :set_user, except: %i[new create search results export]
  before_action :set_user_ids, only: %i[export]
  before_action { authorize User }
  before_action :set_school_if_present, only: %i[new create]
  before_action :set_responsible_body_if_present, only: %i[new create]
  before_action :deny_access_if_school_cannot_invite_users, only: %i[new]

  def new
    @form = Support::NewUserForm.new(school: @school, responsible_body: @responsible_body)
    @user = @school ? @school.users.new : User.new
    authorize @user
    @change_order_devices = user_eligible_to_order_devices?
  end

  def create
    authorize User, :create?
    if @school
      @user = CreateUserService.invite_school_user(user_params.merge(school_id: @school.id))
    elsif @responsible_body
      @user = CreateUserService.invite_responsible_body_user(
        user_params.merge(responsible_body_id: @responsible_body.id),
      )
    end

    if @user.persisted?
      redirect_to support_user_path(@user)
    else
      @form = Support::NewUserForm.new(school: @school, responsible_body: @responsible_body)
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

  def export
    authorize User, :export?
    respond_to do |format|
      format.csv do
        render csv: Support::ExportUsersService.call(@user_ids), filename: 'users'
      end
    end
  end

  def confirm_destroy; end

  def destroy
    DeleteUserService.delete!(@user)

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

  def export_params
    params.permit(:include_audit_data)
  end

  def export_scope
    scope_to_schools? ? school_scope : user_scope
  end

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

  def school_params
    params.permit(:scope_to_schools, school_ids: [])
  end

  def school_ids
    school_params[:school_ids]&.map(&:to_i) || []
  end

  def school_scope
    [:linked_to_school, school_ids]
  end

  def scope_to_schools?
    school_params[:scope_to_schools].to_s.casecmp('true').zero?
  end

  def set_user
    @user = User.not_deleted.find(params[:id])
    authorize @user
  end

  def set_user_ids
    @user_ids = policy_scope(User).send(*export_scope).ids
  end

  def set_school_if_present
    if params[:school_urn]
      @school = School.gias_status_open.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
      authorize @school, :show?
    end
  end

  def user_scope
    export_params['include_audit_data'].to_i == 1 ? :all : :not_deleted_from_responsible_body_or_schools
  end

  def deny_access_if_school_cannot_invite_users
    not_found if @school && !@school.can_invite_users?
  end

  def set_responsible_body_if_present
    if params[:responsible_body_id]
      @responsible_body = ResponsibleBody.gias_status_open.find(params[:responsible_body_id])
      authorize @responsible_body, :show?
    end
  end

  def user_eligible_to_order_devices?(_user = @user)
    SchoolPolicy.new(@user, @school).devices_orderable? if @school
  end
end
