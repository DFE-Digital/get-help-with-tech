class Support::Schools::Devices::AllocationController < Support::BaseController
  before_action :set_school_and_allocation, except: %i[collect_urns_and_allocations_for_many_schools adjust_allocations_for_many_schools]

  def edit
    @form = Support::AllocationForm.new(allocation: @allocation.raw_allocation, school_allocation: @allocation)
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

  def collect_urns_and_allocations_for_many_schools
    authorize School, :edit?
    @form = Support::UrnsAndAllocationsForm.new
  end

  def adjust_allocations_for_many_schools
    authorize School, :edit?
    @form = Support::UrnsAndAllocationsForm.new(urns_and_allocations_form_params)
    @form.parse_urns_and_allocations!
    @job = @form.process!
  end

private

  def device_type
    %w[std_device coms_device].filter { |e| e == params[:device_type] }[0] || 'std_device'
  end
  helper_method :device_type

  def set_school_and_allocation
    @school = School.where_urn_or_ukprn(params[:school_urn]).first!
    authorize @school, :show?
    @allocation = SchoolDeviceAllocation.find_or_initialize_by(school: @school, device_type: device_type)
    authorize @allocation
  end

  def allocation_params
    params.fetch(:support_allocation_form, {}).permit(:allocation)
  end

  def urns_and_allocations_form_params
    params.fetch(:support_urns_and_allocations_form, {}).permit(:urns_and_allocations)
  end

  def update_service
    @update_service ||= AllocationUpdater.new(school: @school, device_type: device_type, value: @form.allocation)
  end
end
