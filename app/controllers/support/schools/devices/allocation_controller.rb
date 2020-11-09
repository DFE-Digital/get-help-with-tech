class Support::Schools::Devices::AllocationController < Support::BaseController
  before_action :set_school_and_allocation

  def edit
    @form = Support::AllocationForm.new(allocation: @allocation.allocation, school_allocation: @allocation)
  end

  def update
    # we need this to be able to show the allocation description based on the
    # values as they were *before* the failed update
    @current_allocation = @allocation.dup
    @form = Support::AllocationForm.new(allocation_params.merge(school_allocation: @allocation))
    if @form.valid?
      update_service.call
      flash[:success] = t(:success, scope: %i[support allocation update])
      redirect_to support_school_path(urn: @school.urn)
    else
      params[:device_type] = device_type
      render :edit, status: :unprocessable_entity
    end
  end

private

  def device_type
    %w[std_device coms_device].filter { |e| e == params[:device_type] }[0] || 'std_device'
  end
  helper_method :device_type

  def set_school_and_allocation
    @school = School.find_by_urn(params[:school_urn])
    @allocation = SchoolDeviceAllocation.find_or_initialize_by(school: @school, device_type: device_type)
  end

  def allocation_params
    params.fetch(:support_allocation_form, {}).permit(:allocation)
  end

  def update_service
    @update_service ||= AllocationUpdater.new(school: @school, device_type: device_type, value: @form.allocation)
  end
end
