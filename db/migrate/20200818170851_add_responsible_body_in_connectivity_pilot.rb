class AddResponsibleBodyInConnectivityPilot < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :in_connectivity_pilot, :boolean, default: true
  end
end
