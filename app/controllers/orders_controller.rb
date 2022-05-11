class OrdersController < ApplicationController
  before_action :require_sign_in!

  def index
    @title = 'Order history'
    all_orders = policy_scope(Computacenter::Order).order(order_date: :desc)
    @pagination, @orders = pagy(all_orders)

    respond_to do |format|
      format.html
      format.csv do
        send_data Computacenter::ExportOrdersService.call(all_orders.pluck(:id)), filename: "#{Time.zone.now.iso8601}_order_history_export.csv"
      end
    end
  end
end
