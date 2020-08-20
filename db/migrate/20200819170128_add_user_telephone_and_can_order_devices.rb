class AddUserTelephoneAndCanOrderDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :telephone, :string
    add_column :users, :can_order_devices, :boolean
  end
end
