class ResponsibleBody::HomeController < ResponsibleBody::BaseController
  def show
    @requests = @user.extra_mobile_data_requests
  end
end
