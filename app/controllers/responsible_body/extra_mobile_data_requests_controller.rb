class ResponsibleBody::ExtraMobileDataRequestsController < ResponsibleBody::BaseController
  def index
    @requests = @user.extra_mobile_data_requests
  end
end
