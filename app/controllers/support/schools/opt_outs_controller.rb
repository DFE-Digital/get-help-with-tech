class Support::Schools::OptOutsController < Support::BaseController
  before_action :set_school
  before_action { authorize @school }

  def edit; end

  def update
    if form_params[:opt_out] == '1'
      @school.opt_out!
      flash[:success] = 'School has been opted out'
    else
      @school.opt_in!
      flash[:success] = 'School has been opted back in'
    end

    redirect_to support_school_path(@school)
  end

private

  def set_school
    @school ||= School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
  end

  def form_params
    params.require(:school).permit(:opt_out)
  end
end
