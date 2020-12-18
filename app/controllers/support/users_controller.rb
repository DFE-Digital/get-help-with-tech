class Support::UsersController < Support::BaseController
  SEARCH_RESULTS_LIMIT = 100

  before_action :set_user, except: %i[new create search results]
  before_action { authorize User }
  before_action :set_school_if_present, only: %i[new create]
  before_action :set_responsible_body_if_present, only: %i[new create]

  def new
    @user = User.new
    authorize @user
  end

  def create
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
    @search_form = Support::UserSearchForm.new(search_params)
    @search_term = @search_form.email_address_or_full_name
    @results = policy_scope(User)
      .search_by_email_address_or_full_name(@search_term)
      .not_deleted
      .distinct
      .includes(:responsible_body, :schools)
      .order(full_name: :asc)
      .limit(SEARCH_RESULTS_LIMIT)
    @maximum_search_result_number_reached = (@results.size == SEARCH_RESULTS_LIMIT)
  end

  def associated_organisations
    @schools = @user.schools.order(:name)
    @responsible_body = @user.responsible_body
    @user_responsible_body_form = Support::UserResponsibleBodyForm.new(
      user: @user,
      possible_responsible_bodies: ResponsibleBody.gias_status_open.order(type: :asc, name: :asc),
    )
    @user_school_form = Support::NewUserSchoolForm.new(user: @user)
  end

  def update_responsible_body
    @user.update!(responsible_body_id: responsible_body_params[:responsible_body])
    flash[:success] = success_message
    redirect_to associated_organisations_support_user_path(@user.id)
  end

  def confirm_destroy; end

  def destroy
    @user.update!(deleted_at: Time.zone.now)

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

  def responsible_body_params
    params.require(:support_user_responsible_body_form).permit(:responsible_body)
  end

  def success_message
    if @user.responsible_body.present?
      "#{@user.full_name} is now associated with #{@user.responsible_body.name}"
    else
      "#{@user.full_name} is no longer associated with a responsible body"
    end
  end

  def set_user
    @user = User.not_deleted.find(params[:id])
    authorize @user
  end

  def set_school_if_present
    if params[:school_urn]
      @school = School.gias_status_open.find_by(urn: params[:school_urn])
      authorize @school, :show?
    end
  end

  def set_responsible_body_if_present
    if params[:responsible_body_id]
      @responsible_body = ResponsibleBody.gias_status_open.find(params[:responsible_body_id])
      authorize @responsible_body, :show?
    end
  end
end
