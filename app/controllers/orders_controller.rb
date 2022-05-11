class OrdersController < ApplicationController
  before_action :require_sign_in!

  def index
    @title = 'Order history'
    @pagination, @orders = pagy(policy_scope(Computacenter::Order).order(order_date: :desc))

    respond_to do |format|
      format.html
      format.csv do
        send_data Computacenter::ExportOrdersService.call(@orders.pluck(:id)), filename: "#{Time.zone.now.iso8601}_order_history_export.csv"
      end
    end
  end
end
