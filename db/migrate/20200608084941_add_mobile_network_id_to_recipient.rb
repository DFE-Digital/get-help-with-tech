class AddMobileNetworkIdToRecipient < ActiveRecord::Migration[6.0]
  def change
    add_column :recipients, :mobile_network_id, :integer, references: :mobile_networks, foreign_key: true, null: true
  end
end
