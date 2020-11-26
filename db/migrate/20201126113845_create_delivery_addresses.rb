class CreateDeliveryAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :delivery_addresses do |t|
      t.references :school

      t.string :computacenter_reference

      t.string :address_1
      t.string :address_2
      t.string :address_3
      t.string :town
      t.string :county
      t.string :postcode

      t.timestamps
    end

    add_index :delivery_addresses, :computacenter_reference
  end
end
