class ResponsibleBody::Internet::Mobile::BulkRequestsController < ResponsibleBody::BaseController
  def new
    @upload_form = BulkUploadForm.new
  end

  def create
    @upload_form = BulkUploadForm.new(upload_form_params)

    if @upload_form.valid?
      importer = importer_for(@upload_form.file.path)
      # parse file and generate records
      begin
        @summary = importer.import!(extra_fields: { created_by_user: @current_user, responsible_body: @current_user.responsible_body })
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
    params.fetch(:bulk_upload_form, {}).permit(%i[upload])
  end

  def importer_for(spreadsheet_path)
    @importer ||= ExtraDataRequestSpreadsheetImporter.new(spreadsheet_path)
  end
end
