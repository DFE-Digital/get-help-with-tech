class School::HomeController < School::BaseController
  def show; end

  def request_devices
    render 'shared/devices/school_request_devices'
  end
end
