class ChangeTypeOfUrnOnAllocationBatchJobs < ActiveRecord::Migration[6.1]
  def up
    change_column :allocation_batch_jobs, :urn, :string
  end

  def down
    change_column :allocation_batch_jobs, :urn, :integer
  end
end
