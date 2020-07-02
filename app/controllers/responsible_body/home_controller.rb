class ResponsibleBody::HomeController < ResponsibleBody::BaseController
  def show
    @allocation_request = @responsible_body.allocation_request
    @requests = @user.extra_mobile_data_requests
  end
end
