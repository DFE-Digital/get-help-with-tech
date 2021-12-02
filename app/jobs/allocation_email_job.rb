class AllocationEmailJob < ApplicationJob
  queue_as :default

  def perform(allocation_batch_job)
    return if allocation_batch_job.sent_notification?

    service = SchoolCanOrderDevicesNotifications.new(allocation_batch_job.school)
    service.call

    allocation_batch_job.update!(sent_notification: true)
  end
end
