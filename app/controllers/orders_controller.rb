class OrdersController < ApplicationController
  before_action :require_sign_in!

  def index
    @title = 'Order history'
    policy_scope = Computacenter::OrderPolicy::Scope.new(impersonated_or_current_user, Computacenter::Order).resolve
    all_orders = policy_scope.is_not_return.order(order_date: :desc).includes(:school)
    @pagination, @orders = pagy(all_orders)

    respond_to do |format|
      format.html
      format.csv do
        send_data Computacenter::ExportOrdersService.call(all_orders.pluck(:id)), filename: "#{Time.zone.now.iso8601}_order_history_export.csv"
      end
    end
  end
end
