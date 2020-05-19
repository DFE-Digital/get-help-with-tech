class CreateRecipients < ActiveRecord::Migration[6.0]
  def change
    create_table :recipients do |t|
      t.string  :full_name
      t.string  :address
      t.string  :postcode
      t.boolean :can_access_hotspot
      t.boolean :is_account_holder
      t.string  :account_holder_name
      t.string  :device_phone_number
      t.string  :phone_network_name
      t.boolean :privacy_statement_sent_to_family
      t.boolean :understands_how_pii_will_be_used

      t.bigint  :created_by_user
      t.timestamps
    end
  end
end
