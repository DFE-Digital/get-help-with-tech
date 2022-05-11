class AddIndexOnOrderDateOnComputacenterOrders < ActiveRecord::Migration[6.1]
  def change
    add_index :computacenter_orders, :order_date
  end
end
