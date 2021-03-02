class DeleteOldSessionsJob < ApplicationJob
  queue_as :default

  def perform
    sessions = Session.where('expires_at < ?', Time.zone.now.utc - 2.hours)
    logger.info "deleting #{sessions.count} sessions expired by 2 hours"
    sessions.destroy_all
  end
end
