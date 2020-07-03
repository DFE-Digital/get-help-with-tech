class ResponsibleBody::ExtraMobileDataRequestsController < ResponsibleBody::BaseController
  def index
    @extra_mobile_data_requests = @user.extra_mobile_data_requests
  end

  def new
    @extra_mobile_data_request = ExtraMobileDataRequest.new
    @participating_mobile_networks = MobileNetwork.participating_in_pilot.order('LOWER(brand)')
  end

private

  def extra_mobile_data_request_params
    params.require(:extra_mobile_data_request).permit(
      [
        :account_holder_name,
        :device_phone_number,
        :mobile_network_id,
        :confirm
      ]
    )
  end
end
