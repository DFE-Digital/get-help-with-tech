class School::HomeController < School::BaseController
  def show; end

  def request_devices
    render 'shared/devices/request_devices'
  end
end
