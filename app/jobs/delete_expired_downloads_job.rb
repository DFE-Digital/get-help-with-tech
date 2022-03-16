class DeleteExpiredDownloadsJob < ApplicationJob
  queue_as :default

  def perform
    deleted_count = Download.delete_expired_downloads!
    logger.info "deleted #{deleted_count} downloads expired by 7 days"
  end
end
