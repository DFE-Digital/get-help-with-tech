class ResponsibleBody::Internet::Mobile::ExtraDataRequestsController < ResponsibleBody::BaseController
  before_action { render_404_unless_responsible_body_has_connectivity_feature_flags(@responsible_body) }

  def index
    @pagination, @extra_mobile_data_requests = pagy(@responsible_body.extra_mobile_data_requests.order(:created_at))
    @statuses_with_descriptions = statuses_with_descriptions
  end

  def show
    @request = @responsible_body.extra_mobile_data_requests.find(params[:id])
  end

private

  def submission_type_params
    # if the user does not choose an option there will be no
    # :extra_mobile_data_sumbission_form in the params
    # Using params.require will raise
    # ActionController::ParameterMissing in that instance
    params.fetch(:extra_mobile_data_submission_form, {}).permit(%i[
      submission_type
    ])
  end

  def statuses_with_descriptions
    ExtraMobileDataRequest
      .statuses_that_school_and_rb_users_can_see
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
