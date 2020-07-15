class ResponsibleBody::HomeController < ResponsibleBody::BaseController
  def show
    if FeatureFlag.inactive?(:extra_mobile_data_offer)
      redirect_to download_responsible_body_bt_wifi_vouchers_path
    else
      @requests = @user.extra_mobile_data_requests
    end
  end
end
