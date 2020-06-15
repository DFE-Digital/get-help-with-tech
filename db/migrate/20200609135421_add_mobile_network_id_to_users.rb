class AddMobileNetworkIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :mobile_network_id, :integer, references: :mobile_networks, foreign_key: true, null: true

    add_index :users, :mobile_network_id
  end
end
