class Support::BulkAllocationForm
  include ActiveModel::Model

  attr_accessor :upload
  attr_reader :send_notification

  validates :upload, presence: { message: 'Select a CSV to upload' }
  validates :send_notification, inclusion: { in: [true, false], message: 'Select whether or not to send user notifications' }

  def send_notification=(value)
    @send_notification = ActiveModel::Type::Boolean.new.cast(value)
  end
end
