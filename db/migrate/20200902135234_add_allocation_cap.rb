class AddAllocationCap < ActiveRecord::Migration[6.0]
  def change
    add_column :school_device_allocations, :cap, :integer, null: false, default: 0
    add_index :school_device_allocations, [:cap]
  end
end
