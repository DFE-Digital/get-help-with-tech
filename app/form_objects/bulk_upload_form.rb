class BulkUploadForm
  include ActiveModel::Model
  attr_accessor :upload
  validate :appropriate_file_chosen

  def file
    upload.tempfile
  end

private

  def appropriate_file_chosen
    if upload
      Rails.logger.debug("Bulk upload content-type: #{upload.content_type}")
      errors.add(:upload, I18n.t('errors.bulk_upload_form.theres_a_problem_with_that_spreadsheet')) unless upload.content_type == Mime::Type.lookup_by_extension(:xlsx)
    else
      errors.add(:upload, I18n.t('errors.bulk_upload_form.select_a_spreadsheet_file'))
    end
  end
end
