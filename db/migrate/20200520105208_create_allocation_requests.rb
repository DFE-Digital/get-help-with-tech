class CreateAllocationRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :allocation_requests do |t|
      t.integer :number_eligible
      t.integer :number_eligible_with_hotspot_access

      t.bigint  :created_by_user
      t.timestamps
    end
  end
end
