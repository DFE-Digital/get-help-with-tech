class Support::AllocationBatchJobsController < Support::BaseController
  before_action { authorize AllocationBatchJob }

  attr_reader :batch_id

  def index
    @batches = AllocationBatchJob.select('batch_id, max(created_at) as created_at').group(:batch_id).order('max(created_at) desc')
  end

  def show
    @batch_id = params[:id]
    query = AllocationBatchJob.where(batch_id:)
    @pagination, @jobs = pagy(query.select('ABS(allocation_delta::INTEGER - applied_allocation_delta::INTEGER) delta_mismatch, *')
                                  .order('delta_mismatch desc, urn, ukprn'))
    @aggregate_allocation_change = query.sum(:applied_allocation_delta)
    @number_of_processed_jobs = query.where(processed: true).size
    @total_number_of_jobs = query.size
  end

  def send_notifications
    jobs = AllocationBatchJob.where(batch_id: params[:id])

    jobs.each do |job|
      AllocationEmailJob.perform_later(job)
    end

    flash[:success] = 'Sending notifications...'

    redirect_to support_allocation_batch_job_path(id: jobs.first.batch_id)
  end
end
