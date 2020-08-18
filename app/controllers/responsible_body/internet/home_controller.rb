class ResponsibleBody::Internet::HomeController < ResponsibleBody::Internet::BaseController
  def show
    @requests = @user.extra_mobile_data_requests
  end
end
