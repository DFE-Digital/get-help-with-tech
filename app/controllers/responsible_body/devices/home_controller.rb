class ResponsibleBody::Devices::HomeController < ResponsibleBody::BaseController
  def show
    redirect_to responsible_body_devices_tell_us_path if @responsible_body.who_will_order_devices.nil?
  end

  def tell_us; end
end
