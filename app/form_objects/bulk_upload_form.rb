class BulkUploadForm
  include ActiveModel::Model
  attr_accessor :upload

  validates :upload, presence: true
  validate :appropriate_file_type, if: ->(form) { form.upload.present? }

  def file
    upload.tempfile
  end

private

  def appropriate_file_type
    Rails.logger.debug("Bulk upload content-type: #{upload.content_type}")
    errors.add(:upload, :unsupported_file_type) unless xlsx_uploaded?
  end

  def xlsx_uploaded?
    upload.content_type == Mime::Type.lookup_by_extension(:xlsx)
  end
end
