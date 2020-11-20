class AddAllocationToVirtualPool < ActiveRecord::Migration[6.0]
  def change
    add_column :virtual_cap_pools, :allocation, :integer, null: false, default: 0
    add_index :virtual_cap_pools, %i[device_type responsible_body_id], unique: true
  end
end
