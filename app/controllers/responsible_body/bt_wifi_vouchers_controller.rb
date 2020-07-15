class ResponsibleBody::BTWifiVouchersController < ResponsibleBody::BaseController
  def index
    vouchers = @responsible_body.bt_wifi_vouchers.order('username asc')
    respond_to do |format|
      format.csv do
        render csv: vouchers, filename: "bt-wifi-vouchers-#{Time.now.iso8601}"
      end
    end
  end

  def download; end
end
