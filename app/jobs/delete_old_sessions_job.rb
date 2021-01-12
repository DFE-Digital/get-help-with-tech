class DeleteOldSessionsJob < ApplicationJob
  queue_as :default

  def perform(args = {})
    older_than = args[:older_than] || Time.zone.now.utc - Settings.session_ttl_seconds * 4
    # We'll play safe & only delete sessions that are 4 times older than the ttl
    sessions = Session.where('updated_at < ?', older_than)
    logger.info "deleting #{sessions.count} sessions older than #{older_than.iso8601}"
    sessions.delete_all
  end
end
