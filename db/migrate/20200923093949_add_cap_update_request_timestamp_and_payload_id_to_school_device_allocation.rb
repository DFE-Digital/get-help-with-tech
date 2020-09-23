class AddCapUpdateRequestTimestampAndPayloadIdToSchoolDeviceAllocation < ActiveRecord::Migration[6.0]
  def change
    add_column :school_device_allocations, :cap_update_request_timestamp, :datetime, null: true
    add_column :school_device_allocations, :cap_update_request_payload_id, :string, null: true

    add_index :school_device_allocations, :cap_update_request_timestamp, name: 'ix_allocations_cap_update_timestamp'
    add_index :school_device_allocations, :cap_update_request_payload_id, name: 'ix_allocations_cap_update_payload_id'
  end
end
