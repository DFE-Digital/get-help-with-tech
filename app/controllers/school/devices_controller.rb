class School::DevicesController < School::BaseController
  def order
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
