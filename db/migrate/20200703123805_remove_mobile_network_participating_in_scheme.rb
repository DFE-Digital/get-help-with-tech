class RemoveMobileNetworkParticipatingInScheme < ActiveRecord::Migration[6.0]
  def change
    remove_column :mobile_networks, :participating_in_scheme, :boolean
  end
end
