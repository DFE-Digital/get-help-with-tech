class AddCapUsageUpdatePayloadIdToDevicesOrderedUpdate < ActiveRecord::Migration[6.1]
  def change
    add_column :computacenter_devices_ordered_updates, :cap_usage_update_payload_id, :integer
    add_foreign_key :computacenter_devices_ordered_updates, :computacenter_cap_usage_update_payloads,
                    column: 'cap_usage_update_payload_id'
    add_index :computacenter_devices_ordered_updates, :cap_usage_update_payload_id,
              name: 'index_devices_ordered_updates_on_cap_usage_update_payload_id'
  end
end
