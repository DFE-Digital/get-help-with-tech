class NotifyComputacenterOfCapUpdateJob < ApplicationJob
  queue_as :slack_messages

  # NOTE: we only pass the allocation_ids, not the amounts to update the caps to.
  # This way, the new caps get read at the time the job is performed rather than
  # when it was scheduled - so if there are several jobs queued up, it doesn't
  # matter if the jobs get processed in the right order or not, the last job
  # processed will always set the latest value.
  def perform(school_device_allocation_ids)
    Computacenter::CapUpdateAPIClient.post_cap_updates_for(school_device_allocation_ids)
  end
end
