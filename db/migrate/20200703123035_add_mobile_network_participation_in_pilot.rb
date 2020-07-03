class AddMobileNetworkParticipationInPilot < ActiveRecord::Migration[6.0]
  def change
    add_column :mobile_networks, :participation_in_pilot, :string, null: true

    add_index :mobile_networks, %i[participation_in_pilot brand]
  end
end
