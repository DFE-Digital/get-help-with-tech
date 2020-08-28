class ResponsibleBody::Devices::KeyContactUploadForm
  include ActiveModel::Model
  attr_accessor :upload
  validate :appropriate_file_chosen

  def file
    upload.tempfile
  end

private

  def appropriate_file_chosen
    errors.add(:upload, I18n.t('errors.key_contact_upload_form.select_a_csv_file')) unless upload
  end
end
