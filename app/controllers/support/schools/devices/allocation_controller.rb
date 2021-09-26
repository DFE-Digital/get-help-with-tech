class Support::Schools::Devices::AllocationController < Support::BaseController
  before_action :set_school

  attr_reader :device_type, :form, :school

  def edit
    @form = Support::AllocationForm.new(form_params.merge(allocation: raw_allocation))
  end

  def update
    @form = Support::AllocationForm.new(form_params.merge(allocation_params))

    if form.save
      flash[:success] = t(:success, scope: %i[support allocation update])
      redirect_to support_school_path(urn: school.urn)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def allocation_params
    params.fetch(:support_allocation_form, {}).permit(:allocation).to_h
  end

  def form_params
    { device_type: device_type, school: school }
  end

  def raw_allocation
    school.send("raw_#{device_type}_allocation")
  end

  def set_school
    @device_type = params[:device_type] == :router ? :router : :laptop
    @school = School.where_urn_or_ukprn_or_provision_urn(params[:school_urn]).first!
    authorize @school, :edit?
  end
end
