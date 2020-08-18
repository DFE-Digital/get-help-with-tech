class AddResponsibleBodyInDevicesPilot < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :in_devices_pilot, :boolean, default: false
  end
end
