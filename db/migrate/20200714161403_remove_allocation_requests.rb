class RemoveAllocationRequests < ActiveRecord::Migration[6.0]
  def up
    drop_table :allocation_requests
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
