class School::DevicesController < School::BaseController
  def order
    if @school.can_order? && @school.can_order_devices?
      render :can_order
    elsif @school.can_order_for_specific_circumstances? && @school.can_order_devices?
      render :can_order_for_specific_circumstances
    else
      render :cannot_order
    end
  end

  def request_devices
    render 'shared/devices/request_devices'
  end
end
