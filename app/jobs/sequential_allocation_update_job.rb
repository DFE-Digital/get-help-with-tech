class SequentialAllocationUpdateJob < ApplicationJob
  def perform(batch_id)
    AllocationBatchJob.where(batch_id: batch_id).find_each do |allocation_batch_job|
      AllocationJob.perform_now(allocation_batch_job)
    end
  end
end
