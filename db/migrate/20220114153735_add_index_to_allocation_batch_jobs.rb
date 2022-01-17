class AddIndexToAllocationBatchJobs < ActiveRecord::Migration[6.1]
  def up
    add_index :allocation_batch_jobs,
              'ABS(allocation_delta::INTEGER - applied_allocation_delta::INTEGER) desc, urn, ukprn',
              name: 'idx_delta_mismatch_urn_ukprn',
              using: 'btree'
  end

  def down
    remove_index :allocation_batch_jobs, name: 'idx_delta_mismatch_urn_ukprn'
  end
end
