class AddEffectiveAllocationDeltaToAllocationBatchJob < ActiveRecord::Migration[6.1]
  def change
    add_column :allocation_batch_jobs, :applied_allocation_delta, :integer
  end
end
