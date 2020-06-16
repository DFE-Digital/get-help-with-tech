class AddMobileNetworks < ActiveRecord::Migration[6.0]
  def change
    create_table :mobile_networks do |t|
      t.string      :brand
      t.string      :host_network
      t.boolean     :participating_in_scheme
      t.timestamps
    end

    add_index :mobile_networks, :brand, unique: true
    add_index :mobile_networks, %i[host_network brand], unique: true
  end
end
