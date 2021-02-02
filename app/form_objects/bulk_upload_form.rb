class BulkUploadForm
  include ActiveModel::Model
  attr_accessor :upload

  validates :upload, presence: true
  validate :appropriate_file_type, :spreadsheet_valid, if: ->(form) { form.upload.present? }

  def spreadsheet
    @spreadsheet ||= ExtraMobileDataRequestSpreadsheet.new(path: upload.tempfile.path)
  end

private

  def appropriate_file_type
    Rails.logger.info("Bulk upload content-type: #{upload.content_type}")
    errors.add(:upload, :unsupported_file_type) unless xlsx_uploaded?
  end

  def spreadsheet_valid
    if spreadsheet.invalid?
      errors.copy!(spreadsheet.errors)
    end
  end

  def xlsx_uploaded?
    upload.content_type == Mime::Type.lookup_by_extension(:xlsx)
  end
end
