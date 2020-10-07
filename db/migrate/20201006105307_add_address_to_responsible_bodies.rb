class AddAddressToResponsibleBodies < ActiveRecord::Migration[6.0]
  def change
    change_table :responsible_bodies do |t|
      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :town
      t.string :county
      t.string :postcode
    end
  end
end
