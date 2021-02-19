class SetGiffgaffToParticipatingInPilot < ActiveRecord::Migration[6.1]
  def up
    MobileNetwork.find_by_brand('giffgaff').update(participation_in_pilot: 'yes')
  end

  def down
    MobileNetwork.find_by_brand('giffgaff').update(participation_in_pilot: 'no')
  end
end
