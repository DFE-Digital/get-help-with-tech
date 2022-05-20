class AddRestrictedDevicesCommsOptOutToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :restricted_devices_comms_opt_out, :boolean, default: false
  end
end
