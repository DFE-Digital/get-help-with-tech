class AddVodafoneToParticipatingMnoList < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        mno = MobileNetwork.find_by(brand: 'Vodafone')
        mno.users.delete_all
        mno.participating!
      end
      dir.down { MobileNetwork.find_by(brand: 'Vodafone')&.not_participating! }
    end
  end
end
