class SetLebaraMobileToParticipating < ActiveRecord::Migration[6.1]
  def up
    MobileNetwork.where(brand: 'Lebara Mobile').update_all(participation_in_pilot: 'yes')
  end

  def down
    MobileNetwork.where(brand: 'Lebara Mobile').update_all(participation_in_pilot: 'no')
  end
end
