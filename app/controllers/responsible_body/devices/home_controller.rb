class ResponsibleBody::Devices::HomeController < ResponsibleBody::Devices::BaseController
  def show
    redirect_to responsible_body_devices_schools_path if @responsible_body.who_will_order_devices.present?
  end
end
