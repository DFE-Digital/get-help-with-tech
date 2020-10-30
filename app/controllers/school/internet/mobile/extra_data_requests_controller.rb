class School::Internet::Mobile::ExtraDataRequestsController < School::BaseController
  before_action { render_404_unless_school_in_mno_feature(@school) }

  def index
    @extra_mobile_data_requests = @school.extra_mobile_data_requests
  end

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
