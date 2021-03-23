class RmRbConnectivityPilot < ActiveRecord::Migration[6.1]
  def change
    remove_column :responsible_bodies, :in_connectivity_pilot, :boolean, default: false
  end
end
