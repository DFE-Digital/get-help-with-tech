class AddWhoWillOrderToResponsibleBody < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :who_will_order_devices, :string
  end
end
