class ChangeTypeOfUrnOnAllocationBatchJobs < ActiveRecord::Migration[6.1]
  def change
    change_column :allocation_batch_jobs, :urn, :string
  end
end
