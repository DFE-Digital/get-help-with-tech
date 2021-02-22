class Support::ExtraMobileDataRequestsController < Support::BaseController
  before_action { authorize ExtraMobileDataRequest }

  def index
    @form = Support::ExtraMobileDataRequestSearchForm.new(search_params)
    @pagination, @requests = pagy(@form.requests(current_user).order(:created_at))

    @statuses_with_descriptions = statuses_with_descriptions
  end

private

  def search_params
    params.fetch(:emdr_search, {})
          .permit(:request_id, :school_id, :urn_or_ukprn, :rb_id, :mno_id, :status)
  end

  def statuses_with_descriptions
    ExtraMobileDataRequest
      .statuses.keys
      .collect do |status|
        [
          status,
          I18n.t!(
            "#{status}.school_or_rb_user_description",
            scope: %i[activerecord attributes extra_mobile_data_request status],
          ),
        ]
      end
  end
end
