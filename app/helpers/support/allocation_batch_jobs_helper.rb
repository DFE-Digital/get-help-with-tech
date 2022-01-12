module Support::AllocationBatchJobsHelper
  def aggregate_allocation_change(jobs)
    jobs.sum { |job| job.applied_allocation_delta.to_i }
  end

  def processed_jobs(jobs)
    "#{jobs.count(&:processed)} / #{jobs.size}"
  end
end
