class CalculateVcapJob < ApplicationJob
  queue_as :default

  attr_reader :batch_id, :responsible_body

  def perform(responsible_body_id:, batch_id:, notify_school: true)
    @responsible_body = ResponsibleBody.find(responsible_body_id)
    @batch_id = batch_id
    process_allocation_batch_jobs
    responsible_body.calculate_vcap(:laptop, notify_computacenter: true, notify_school: notify_school)
  end

private

  def allocation_batch_jobs
    vcap_schools = Array(responsible_body.vcap_schools.pluck(:urn, :ukprn))
    jobs = AllocationBatchJob.where(batch_id: batch_id, urn: vcap_schools.map(&:first).compact).to_a
    jobs += AllocationBatchJob.where(batch_id: batch_id, ukprn: vcap_schools.map(&:last).compact).to_a
    jobs.uniq
  end

  def process_allocation_batch_jobs
    allocation_batch_jobs.each do |allocation_batch_job|
      AllocationJob.new.perform(allocation_batch_job, notify_computacenter: false, recalculate_vcaps: false)
    end
  end
end
