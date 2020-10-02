class ResponsibleBody::Internet::Mobile::ExtraDataRequestsController < ResponsibleBody::BaseController
  before_action only: :new do
    render_404_if_feature_flag_inactive(:mno_offer)
  end

  def index
    @extra_mobile_data_requests = @responsible_body.extra_mobile_data_requests
  end

  def new
    if params.fetch(:commit, '') == 'Continue'
      @submission_type = ExtraMobileDataSubmissionForm.new(submission_type_params)

      if @submission_type.valid?
        if @submission_type.manual?
          redirect_to new_responsible_body_internet_mobile_manual_request_path
        else
          redirect_to new_responsible_body_internet_mobile_bulk_request_path
        end
      else
        render :new, status: :unprocessable_entity
      end
    else
      @submission_type = ExtraMobileDataSubmissionForm.new
    end
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
end
