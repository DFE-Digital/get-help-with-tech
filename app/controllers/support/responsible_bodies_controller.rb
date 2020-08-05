class Support::ResponsibleBodiesController < Support::BaseController
  def index
    @responsible_bodies = ResponsibleBody
      .includes(:bt_wifi_voucher_allocation)
      .joins(:users)
      .distinct
      .order('type asc, name asc')
  end
end
