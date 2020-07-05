class DropUnusedFieldsOnExtraMobileDataRequest < ActiveRecord::Migration[6.0]
  def change
    remove_column :extra_mobile_data_requests, :phone_network_name, :string
    remove_column :extra_mobile_data_requests, :privacy_statement_sent_to_family, :boolean
    remove_column :extra_mobile_data_requests, :understands_how_pii_will_be_used, :boolean
    remove_column :extra_mobile_data_requests, :can_access_hotspot, :boolean
    remove_column :extra_mobile_data_requests, :is_account_holder, :boolean
  end
end
