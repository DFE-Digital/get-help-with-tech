class ResponsibleBody::Devices::HomeController < ResponsibleBody::BaseController
  def show
    redirect_to responsible_body_devices_tell_us_path if @responsible_body.default_who_will_order_devices_for_schools.nil?
  end

  def tell_us; end
end
