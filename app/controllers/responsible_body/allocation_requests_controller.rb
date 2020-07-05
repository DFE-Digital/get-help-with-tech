class ResponsibleBody::AllocationRequestsController < ResponsibleBody::BaseController
  def new
    @allocation_request = AllocationRequest.new
  end

  def check_your_answers
    @allocation_request = AllocationRequest.new(allocation_request_params)
  end

  def create
    allocation_request = AllocationRequest.new(
      allocation_request_params.merge(
        responsible_body: @user.responsible_body,
        created_by_user: @user,
      ),
    )
    allocation_request.save!(validate: false)
    redirect_to responsible_body_home_path
  end

private

  def allocation_request_params
    params.require(:allocation_request).permit(
      :number_eligible,
    )
  end
end
