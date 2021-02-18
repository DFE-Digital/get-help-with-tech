class AddOptInChoiceToDonatedDeviceRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :donated_device_requests, :opt_in_choice, :string
  end
end
