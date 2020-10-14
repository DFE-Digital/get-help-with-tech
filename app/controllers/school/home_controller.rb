class School::HomeController < School::BaseController
  def show
    @allocation = @school.std_device_allocation&.allocation || 0
  end

  def request_devices
    render 'shared/devices/request_devices'
  end
end
