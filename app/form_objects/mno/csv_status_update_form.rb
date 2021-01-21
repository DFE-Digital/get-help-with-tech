class Mno::CsvStatusUpdateForm
  include ActiveModel::Model

  attr_accessor :upload

  validates :upload, presence: { message: 'Select a CSV file' }
  validate :appropriate_file_type, :csv_file_valid, if: ->(form) { form.upload.present? }

  def csv
    @csv ||= ExtraMobileDataRequestStatusFile.new(upload.tempfile.path)
  end

private

  def appropriate_file_type
    Rails.logger.debug("ExtraMobileDataRequestsCsvUpdate content-type: #{upload.content_type}")
    errors.add(:upload, :unsupported_file_type) unless csv_uploaded?
  end

  def csv_file_valid
    errors.add(:upload, 'File has no content') unless File.size?(upload.tempfile.path)
  end

  def csv_uploaded?
    upload.content_type == Mime::Type.lookup_by_extension(:csv)
  end
end
