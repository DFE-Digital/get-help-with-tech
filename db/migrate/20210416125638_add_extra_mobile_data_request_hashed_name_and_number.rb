class AddExtraMobileDataRequestHashedNameAndNumber < ActiveRecord::Migration[6.1]
  def change
    add_column :extra_mobile_data_requests, :hashed_account_holder_name, :string, null: true
    add_column :extra_mobile_data_requests, :hashed_normalised_name, :string, null: true
    add_column :extra_mobile_data_requests, :hashed_device_phone_number, :string, null: true

    add_index :extra_mobile_data_requests, :hashed_account_holder_name
    add_index :extra_mobile_data_requests, :hashed_normalised_name
    add_index :extra_mobile_data_requests, :hashed_device_phone_number
  end
end
