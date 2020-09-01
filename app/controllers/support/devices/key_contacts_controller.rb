class Support::Devices::KeyContactsController < Support::BaseController
  def new
    @upload_form = ResponsibleBody::Devices::KeyContactUploadForm.new
  end

  def create
    @upload_form = ResponsibleBody::Devices::KeyContactUploadForm.new(upload_form_params)
    if @upload_form.valid?
      # parse file and generate records
      begin
        @summary = importer.import_contacts
        render :summary
      rescue StandardError => e
        Rails.logger.error(e.message)
        @upload_form.errors.add(:upload, I18n.t('errors.key_contact_upload_form.theres_a_problem_with_that_file'))
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def upload_form_params
    params.fetch(:responsible_body_devices_key_contact_upload_form, {}).permit(%i[upload])
  end

  def importer
    @importer ||= KeyContactsImporter.new(KeyContactDataFile.new(@upload_form.file.path))
  end
end
