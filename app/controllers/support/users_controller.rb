class Support::UsersController < Support::BaseController
  SEARCH_RESULTS_LIMIT = 100

  before_action { authorize User }

  def search
    @search_form = Support::UserSearchForm.new
  end

  def results
    @search_form = Support::UserSearchForm.new(search_params)
    @search_term = @search_form.email_address_or_full_name
    @results = policy_scope(User)
      .from_responsible_body_or_schools
      .search_by_email_address_or_full_name(@search_term)
      .distinct
      .includes(:responsible_body, :schools)
      .order(full_name: :asc)
      .limit(SEARCH_RESULTS_LIMIT)
    @maximum_search_result_number_reached = (@results.size == SEARCH_RESULTS_LIMIT)
  end

private

  def search_params
    params.require(:support_user_search_form).permit(:email_address_or_full_name)
  end
end
