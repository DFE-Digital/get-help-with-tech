class Support::UsersController < Support::BaseController
  SEARCH_RESULTS_LIMIT = 100

  before_action :set_user, only: %i[associated_organisations update_responsible_body]
  before_action { authorize User }

  def search
    @search_form = Support::UserSearchForm.new
  end

  def results
    @search_form = Support::UserSearchForm.new(search_params)
    @search_term = @search_form.email_address_or_full_name
    @results = policy_scope(User)
      .search_by_email_address_or_full_name(@search_term)
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

private

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
    @user = policy_scope(User).find(params[:id])
  end
end
