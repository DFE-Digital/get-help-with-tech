class Support::Devices::AllocationController < Support::BaseController
  before_action :set_school_and_allocation

  def edit
    @form = Support::AllocationForm.new(allocation: @allocation.allocation, school_device_allocation: @allocation)
  end

  def update
    # we need this to be able to show the allocation description based on the
    # values as they were *before* the failed update
    @current_allocation = @allocation.dup
    @form = Support::AllocationForm.new(allocation_params.merge(school_device_allocation: @allocation))
    if @form.valid?
      @allocation.update!(allocation: @form.allocation)
      flash[:success] = t(:success, scope: %i[support allocation update])
      redirect_to support_devices_school_path(urn: @school.urn)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def set_school_and_allocation
    @school = School.find_by_urn(params[:school_urn])
    @allocation = SchoolDeviceAllocation.find_or_initialize_by(school: @school, device_type: 'std_device')
  end

  def allocation_params
    params.fetch(:support_allocation_form, {}).permit(:allocation)
  end
end
