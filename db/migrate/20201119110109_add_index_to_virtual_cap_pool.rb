class AddIndexToVirtualCapPool < ActiveRecord::Migration[6.0]
  def change
    add_index :virtual_cap_pools, :responsible_body_id
  end
end
