class Support::DevicesController < Support::BaseController
  def new
    @upload_form = KeyContactUploadForm.new
  end

  def create
    @upload_form = KeyContactUploadForm.new(upload_form_params)

    if @upload_form.valid?
      # parse file and generate records
      begin
        @summary = importer.import_contacts!
        render :summary
      rescue StandardError => e
        Rails.logger.error(e.message)
        @upload_form.errors.add(:upload, I18n.t('errors.bulk_upload_form.theres_a_problem_with_that_spreadsheet'))
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def upload_form_params
    params.fetch(:key_contact_upload_form, {}).permit(%i[upload])
  end

  def importer
    @importer ||= KeyContactsImporter.new(@upload_form.file.path,
                                          @user)
  end
end
