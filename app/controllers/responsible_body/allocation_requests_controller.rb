class ResponsibleBody::AllocationRequestsController < ResponsibleBody::BaseController
  def new
    @allocation_request = AllocationRequest.new
  end

  def check_your_answers
  end

  def create
    allocation_request = AllocationRequest.new(
      responsible_body: @user.responsible_body,
      created_by_user: @user,
    )
    allocation_request.save!(validate: false)
    redirect_to responsible_body_home_path
  end
end
