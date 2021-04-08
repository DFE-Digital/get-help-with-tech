class CreateAllocationBatchJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :allocation_batch_jobs do |t|
      t.text :batch_id, null: false
      t.integer :urn
      t.integer :ukprn
      t.integer :allocation_delta, null: false
      t.text :order_state
      t.boolean :send_notification, null: false, default: true
      t.boolean :processed, null: false, default: false

      t.timestamps
    end

    add_index :allocation_batch_jobs, :batch_id
  end
end
