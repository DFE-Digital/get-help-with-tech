# frozen_string_literal: true

require 'active_job/queue_adapters/sidekiq_adapter'

module ActiveJob
  module QueueAdapters
    # Simple workaround for a timing issue / race condition whereby jobs
    # (particularly notification-of-update-style jobs) get pulled off the job
    # queue and processed before the database transaction containing the change
    # which caused them is committed to the DB.
    # This means that the job or mailer, which runs in a separate
    # Sidekiq process, often can't see the change which triggered the job.
    # The simplest fix for this is just to add a short delay to all async jobs
    class SidekiqWithEnforcedDelayAdapter < SidekiqAdapter
      def enqueue(job)
        enqueue_at(job, (Time.zone.now.utc + Settings.active_job.default_wait.seconds).to_i)
      end
    end
  end
end
