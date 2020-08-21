class ResponsibleBody::Internet::BTWifiVouchersController < ResponsibleBody::BaseController
  def index
    vouchers = @responsible_body.bt_wifi_vouchers.order('username asc')
    respond_to do |format|
      format.csv do
        render csv: vouchers, filename: "bt-wifi-vouchers-#{Time.zone.now.iso8601}"
        vouchers
          .where(distributed_at: nil)
          .touch_all(:distributed_at)
      end
    end
  end

  def download; end
end
