class School::DevicesController < School::BaseController
  def order
    # always false, until we've developed the other branch of the user journey
    if false && @school.can_order_devices?
    else
      render :cannot_order
    end
  end

  def request_devices
    render 'shared/devices/request_devices'
  end
end
