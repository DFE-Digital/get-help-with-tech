require 'csv'

class Support::BulkAllocationForm
  include ActiveModel::Model

  CSV_HEADERS = %w[urn ukprn allocation_delta order_state].freeze

  attr_accessor :upload
  attr_reader :send_notification

  validates :upload, presence: { message: 'Select a CSV to upload' }
  validates :send_notification, inclusion: { in: [true, false], message: 'Select whether or not to send user notifications' }

  def save
    valid? && upload_scheduled?
  end

  def send_notification=(value)
    @send_notification = ActiveModel::Type::Boolean.new.cast(value)
  end

  def batch_id
    @batch_id ||= SecureRandom.uuid
  end

private

  def rows
    @rows ||= CSV.read(upload.path, headers: true)
  end

  def upload_scheduled?
    rows.each do |row|
      job_attrs = row.to_h.slice(*CSV_HEADERS).merge(batch_id: batch_id, send_notification: send_notification)
      AllocationJob.perform_later(AllocationBatchJob.create!(job_attrs))
    end
    true
  rescue StandardError
    false
  end
end
