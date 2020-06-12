class AddStatusToRecipient < ActiveRecord::Migration[6.0]
  def change
    add_column :recipients, :status, :string, null: true

    add_index :recipients, [:status]
    add_index :recipients, %i[mobile_network_id status created_at]
  end
end
