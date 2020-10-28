class RemoveResponsibleBodiesInDevicesPilotFlag < ActiveRecord::Migration[6.0]
  def change
    remove_column :responsible_bodies, :in_devices_pilot, :boolean
  end
end
