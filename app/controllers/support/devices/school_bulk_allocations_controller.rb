class Support::Devices::SchoolBulkAllocationsController < Support::BaseController
  def new
    @form = Support::BulkAllocationForm.new
  end

  def create
    @form = Support::BulkAllocationForm.new(restriction_params)

    if @form.valid?
      @summary = allocation_service.unlock!(@form.urn_list)
      render 'summary'
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def restriction_params
    params.require(:support_bulk_allocation_form).permit(:school_urns)
  end

  def allocation_service
    @allocation_service ||= BulkAllocationService.new
  end
end
