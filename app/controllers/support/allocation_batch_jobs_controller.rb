class Support::AllocationBatchJobsController < Support::BaseController
  before_action { authorize School }

  def index
    @batches = AllocationBatchJob.select('batch_id, max(created_at) as created_at').group(:batch_id).order('max(created_at) desc')
  end

  def show
    @jobs = AllocationBatchJob.where(batch_id: params[:id])
  end
end
