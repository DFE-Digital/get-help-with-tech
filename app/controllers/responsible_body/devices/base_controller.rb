class ResponsibleBody::Devices::BaseController < ResponsibleBody::BaseController
  before_action :require_device_pilot_participation!

private

  def require_device_pilot_participation!
    render 'errors/forbidden', status: :forbidden unless @responsible_body.in_devices_pilot
  end
end
