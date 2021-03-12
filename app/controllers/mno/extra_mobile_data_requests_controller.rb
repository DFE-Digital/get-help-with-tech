class Mno::ExtraMobileDataRequestsController < Mno::BaseController
  def index
    @find_requests_form = Mno::FindRequestsForm.new(find_requests_params)
    @extra_mobile_data_requests = extra_mobile_data_request_search_scope.order(safe_order)

    respond_to do |format|
      format.csv do
        render csv: @extra_mobile_data_requests, filename: "requests-mno-#{@mobile_network.id}-#{Time.zone.now.iso8601}"
      end
      # capybara sends through NullType sometimes
      format.any do
        @pagination, @extra_mobile_data_requests = pagy(@extra_mobile_data_requests)
        @extra_mobile_data_requests_form = Mno::ExtraMobileDataRequestsForm.new(
          extra_mobile_data_requests: @extra_mobile_data_requests,
          extra_mobile_data_request_ids: selected_extra_mobile_data_request_ids(@extra_mobile_data_requests, params),
        )
        @statuses = mno_status_options
        if @find_requests_form.phone_number_list.any?
          render 'search_results'
        else
          if is_a_search_request?
            @find_requests_form.phone_numbers = nil
            @find_requests_form.valid?
          end
          render
        end
      end
    end
  end

  def report_problem
    load_extra_mobile_data_request(params[:extra_mobile_data_request_id])
    @specific_options, @other_option = problem_options
  end

  def update
    load_extra_mobile_data_request(params[:id])
    @extra_mobile_data_request.update!(extra_mobile_data_request_params)
    redirect_to mno_extra_mobile_data_requests_path
  rescue ActiveModel::ValidationError, ActionController::ParameterMissing
    @specific_options, @other_option = problem_options
    render :report_problem, status: :unprocessable_entity
  end

  def bulk_update
    ExtraMobileDataRequest.transaction do
      new_attributes = { status: bulk_update_params[:status] }
      ids = (bulk_update_params[:extra_mobile_data_request_ids] || []).reject(&:empty?)
      extra_mobile_data_request_scope
               .where('extra_mobile_data_requests.id IN (?)', ids)
               .update_all(new_attributes)
      redirect_to mno_extra_mobile_data_requests_path(find_requests_params)
    rescue ActiveRecord::StatementInvalid, ArgumentError => e
      logger.error e
      flash[:error] = "I couldn't apply that update"
      render :index, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    end
  end

private

  def problem_options
    ExtraMobileDataRequest
      .problem_statuses
      .map { |status| option_for(status) }
      .partition { |option| option.value != 'problem_other' }
  end

  def option_for(status)
    OpenStruct.new(
      value: status,
      label: I18n.t!("#{status}.mno_user_description", scope: %i[activerecord attributes extra_mobile_data_request status]),
    )
  end

  def mno_status_options
    ExtraMobileDataRequest
      .statuses_that_mno_users_can_assign
      .map do |status|
        OpenStruct.new(
          value: status,
          label: I18n.t!("#{status}.dropdown_label", scope: %i[activerecord attributes extra_mobile_data_request status]),
        )
      end
  end

  def extra_mobile_data_request_scope
    @mobile_network.extra_mobile_data_requests
  end

  def extra_mobile_data_request_search_scope
    base_scope = extra_mobile_data_request_scope
    requested_numbers = @find_requests_form.phone_number_list

    if requested_numbers.any?
      # a search filter has been applied
      base_scope = base_scope.where(device_phone_number: requested_numbers)
    end
    base_scope
  end

  def load_extra_mobile_data_request(emdr_id)
    @extra_mobile_data_request = extra_mobile_data_request_scope.find(emdr_id)
  end

  def selected_extra_mobile_data_request_ids(extra_mobile_data_requests, opts = params)
    if opts[:select] == 'all'
      extra_mobile_data_requests.pluck(:id)
    elsif opts[:select] == 'none'
      []
    else
      opts[:extra_mobile_data_request_ids]
    end
  end

  def bulk_update_params(opts = params)
    opts.require(:mno_extra_mobile_data_requests_form).permit(
      :status,
      extra_mobile_data_request_ids: [],
    )
  end

  def find_requests_params
    form_params = params.fetch(:mno_find_requests_form, {}).permit(:phone_numbers)
    # once on the find requests page we could get sorting requests for the table of results
    form_params = params.permit(:phone_numbers) if form_params.empty?

    form_params
  end

  def safe_order(opts = params)
    order = db_order_field(opts[:sort])
    if order
      { order => db_dir(opts[:dir]) }
    end
  end

  def db_dir(dir_param)
    dir_param == 'd' ? :desc : :asc
  end

  def db_order_field(order_param)
    {
      'id' => :id,
      'mobile_number' => :device_phone_number,
      'account_holder_name' => :account_holder_name,
      'requested' => :created_at,
      'status' => :status,
    }[order_param]
  end

  def is_a_search_request?
    params.fetch(:commit, '') == 'Find requests'
  end

  def extra_mobile_data_request_params
    params.require(:extra_mobile_data_request).permit(:status)
  end
end
