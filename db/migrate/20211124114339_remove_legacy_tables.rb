class RemoveLegacyTables < ActiveRecord::Migration[6.1]
  def change
    remove_column :schools, :raw_laptop_cap, :integer
    remove_column :schools, :raw_router_cap, :integer
    remove_column :cap_changes, :school_device_allocation_id, :integer
    remove_column :cap_update_calls, :school_device_allocation_id, :integer

    drop_table :school_virtual_caps do |t|
      t.bigint 'virtual_cap_pool_id'
      t.bigint 'school_device_allocation_id'
      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
    end

    drop_table :virtual_cap_pools do |t|
      t.string 'device_type', null: false
      t.bigint 'responsible_body_id', null: false
      t.integer 'cap', default: 0, null: false
      t.integer 'devices_ordered', default: 0, null: false
      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
      t.integer 'allocation', default: 0, null: false
    end

    drop_table :school_device_allocations do |t|
      t.bigint 'school_id'
      t.string 'device_type', null: false
      t.integer 'allocation', default: 0
      t.integer 'devices_ordered', default: 0
      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
      t.bigint 'last_updated_by_user_id'
      t.bigint 'created_by_user_id'
      t.integer 'cap', default: 0, null: false
      t.datetime 'cap_update_request_timestamp'
      t.string 'cap_update_request_payload_id'
    end
  end
end
