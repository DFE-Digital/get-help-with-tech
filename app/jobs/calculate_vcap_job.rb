class CalculateVcapJob < ApplicationJob
  queue_as :default

  attr_reader :batch_id, :responsible_body

  def perform(responsible_body_id:, batch_id:, notify_school: true)
    @responsible_body = ResponsibleBody.find(responsible_body_id)
    @batch_id = batch_id
    process_allocation_batch_jobs
    responsible_body.calculate_vcap(:laptop, notify_computacenter: true, notify_school: notify_school)
    responsible_body.calculate_vcap(:router, notify_computacenter: true, notify_school: notify_school)
  end

private

  def allocation_batch_jobs
    vcap_school_ids = Array(responsible_body.vcap_schools.pluck(:urn, :ukprn)).flatten.uniq.compact
    AllocationBatchJob.distinct.where(batch_id: batch_id, urn: vcap_school_ids)
                      .or(AllocationBatchJob.distinct.where(batch_id: batch_id, ukprn: vcap_school_ids))
  end

  def process_allocation_batch_jobs
    allocation_batch_jobs.each do |allocation_batch_job|
      AllocationJob.new.perform(allocation_batch_job, notify_computacenter: false, recalculate_vcaps: false)
    end
  end
end
