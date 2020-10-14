class ResponsibleBody::Devices::HomeController < ResponsibleBody::Devices::BaseController
  def show
    redirect_to responsible_body_devices_tell_us_path if @responsible_body.who_will_order_devices.nil?
  end

  def tell_us; end

  def reduced_allocations
    render_404_if_feature_flag_inactive(:reduced_allocations)
  end

  def request_devices
    render 'shared/devices/request_devices'
  end
end
