class ResponsibleBody::Internet::HomeController < ResponsibleBody::Internet::BaseController
  def show
    @requests = @current_user.extra_mobile_data_requests
  end
end
