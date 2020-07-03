class PopulateMobileNetworkParticipationInPilot < ActiveRecord::Migration[6.0]
  def up
    MobileNetwork.where(participating_in_scheme: false).update_all(participation_in_pilot: :no)
    MobileNetwork.where(participating_in_scheme: true).update_all(participation_in_pilot: :yes)
  end

  def down
    MobileNetwork.update_all(participation_in_pilot: nil)
  end
end
