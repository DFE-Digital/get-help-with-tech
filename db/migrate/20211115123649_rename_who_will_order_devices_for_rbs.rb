class RenameWhoWillOrderDevicesForRbs < ActiveRecord::Migration[6.1]
  def change
    rename_column :responsible_bodies, :who_will_order_devices, :default_who_will_order_devices_for_schools
  end
end
