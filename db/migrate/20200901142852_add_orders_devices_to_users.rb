class AddOrdersDevicesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :orders_devices, :boolean
  end
end
