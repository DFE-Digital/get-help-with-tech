class Support::AllocationBatchJobsController < Support::BaseController
  before_action { authorize AllocationBatchJob }

  def index
    @batches = AllocationBatchJob.select('batch_id, max(created_at) as created_at').group(:batch_id).order('max(created_at) desc')
  end

  def show
    @jobs = AllocationBatchJob.where(batch_id: params[:id])
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
