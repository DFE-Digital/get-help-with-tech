class School::Internet::Mobile::BulkRequestsController < School::BaseController
  def new
    @upload_form = BulkUploadForm.new
  end

  def create
    authorize ExtraMobileDataRequest, policy_class: School::BasePolicy

    @upload_form = BulkUploadForm.new(upload_form_params)

    if @upload_form.valid?
      importer = importer_for(@upload_form.spreadsheet)
      # parse file and generate records
      begin
        @summary = importer.import!(extra_fields: { created_by_user: @current_user, school: @school })
        render :summary
      rescue StandardError => e
        Rails.logger.error(e.message)
        @upload_form.errors.add(:upload, :theres_a_problem_with_that_spreadsheet)
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

  def importer_for(spreadsheet)
    @importer ||= ExtraDataRequestSpreadsheetImporter.new(spreadsheet)
  end
end
