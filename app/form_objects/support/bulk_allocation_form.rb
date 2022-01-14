class Support::BulkAllocationForm
  include ActiveModel::Model

  attr_accessor :upload
  attr_reader :send_notification

  validates :upload, presence: { message: 'Select a CSV to upload' }
  validates :send_notification, inclusion: { in: [true, false], message: 'Select whether or not to send user notifications' }

  def batch_id
    @batch_id ||= SecureRandom.uuid
  end

  def save
    valid? && upload_scheduled?
  end

  def send_notification=(value)
    @send_notification = ActiveModel::Type::Boolean.new.cast(value)
  end

private

  def upload_scheduled?
    BulkAllocationJob.perform_later(filepath: upload.path,
                                    batch_id: batch_id,
                                    send_notification: send_notification)
    true
  rescue StandardError
    false
  end
end
