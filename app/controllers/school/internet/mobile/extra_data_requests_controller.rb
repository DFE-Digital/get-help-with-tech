class School::Internet::Mobile::ExtraDataRequestsController < School::BaseController
  def index
    @pagination, @extra_mobile_data_requests = pagy(@school.extra_mobile_data_requests.order(:created_at))
    @statuses_with_descriptions = statuses_with_descriptions
  end

  def guidance; end

  def new
    if params.fetch(:commit, '') == 'Continue'
      @submission_type = ExtraMobileDataSubmissionForm.new(submission_type_params)

      if @submission_type.valid?
        if @submission_type.manual?
          redirect_to new_internet_mobile_manual_request_path(@school)
        else
          redirect_to new_internet_mobile_bulk_request_path(@school)
        end
      else
        render :new, status: :unprocessable_entity
      end
    else
      @submission_type = ExtraMobileDataSubmissionForm.new
    end
  end

  def show
    @request = @school.extra_mobile_data_requests.find(params[:id])
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
