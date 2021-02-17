class Support::UserSearchForm
  SEARCH_RESULTS_LIMIT = 100

  include ActiveModel::Model

  attr_accessor :email_address_or_full_name, :scope

  def results
    @results ||= scope
      .search_by_email_address_or_full_name(email_address_or_full_name)
      .not_deleted
      .distinct
      .includes(:responsible_body, :schools)
      .order(full_name: :asc)
      .limit(SEARCH_RESULTS_LIMIT)
  end

  def related_results
    @related_results ||=
      begin
        if results.empty?
          suffix = "@#{Mail::Address.new(email_address_or_full_name).domain}".strip

          scope
          .where('email_address ILIKE ?', "%#{suffix}")
          .not_deleted
          .distinct
          .includes(:responsible_body, :schools)
          .order(full_name: :asc)
          .limit(SEARCH_RESULTS_LIMIT)
        else
          []
        end
      rescue StandardError
        []
      end
  end

  def maximum_search_result_number_reached?
    @maximum_search_result_number_reached ||= (results.size == SEARCH_RESULTS_LIMIT)
  end
end
