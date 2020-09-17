class School::DevicesController < School::BaseController
  def order
    # replace with if conditon below when we've developed the other
    # branch of the user journey
    # if false && @school.can_order_devices?
    # else
    if @school.can_order_devices?
      render :order
    else
      render :cannot_order
    end
  end

  def request_devices
    render 'shared/devices/request_devices'
  end
end
