class ResponsibleBody::ExtraMobileDataRequestsController < ResponsibleBody::BaseController
  def index
    @extra_mobile_data_requests = @user.extra_mobile_data_requests
  end

  def new; end
end
