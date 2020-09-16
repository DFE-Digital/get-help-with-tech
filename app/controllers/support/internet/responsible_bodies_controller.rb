class Support::Internet::ResponsibleBodiesController < Support::BaseController
  def index
    @responsible_bodies = ResponsibleBody
      .in_connectivity_pilot
      .includes(:bt_wifi_voucher_allocation, :bt_wifi_vouchers)
      .joins(:users)
      .distinct
      .order('type asc, name asc')
  end

  def show
    @responsible_body = ResponsibleBody.find(params[:id])
    @users = @responsible_body.users.order('last_signed_in_at desc nulls last, updated_at desc')
  end
end
