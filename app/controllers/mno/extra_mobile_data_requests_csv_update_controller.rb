class Mno::ExtraMobileDataRequestsCsvUpdateController < Mno::BaseController
  def new
    @upload_form = Mno::CsvStatusUpdateForm.new
    @statuses_with_descriptions = statuses_with_descriptions
  end

  def create
    @upload_form = Mno::CsvStatusUpdateForm.new(upload_form_params)

    if @upload_form.valid?
      importer = importer_for(@upload_form.csv)
      begin
        @summary = importer.import!
        render :summary
      rescue StandardError => e
        Rails.logger.error(e.message)
        @upload_form.errors.add(:upload, :theres_a_problem_with_that_csv)
        @statuses_with_descriptions = statuses_with_descriptions
        render :new, status: :unprocessable_entity
      end
    else
      @statuses_with_descriptions = statuses_with_descriptions
      render :new, status: :unprocessable_entity
    end
  end

private

  def upload_form_params
    params.fetch(:mno_csv_status_update_form, {}).permit(%i[upload])
  end

  def importer_for(csv)
    @importer ||= ExtraMobileDataRequestStatusImporter.new(mobile_network: @mobile_network, datasource: csv)
  end

  def statuses_with_descriptions
    ExtraMobileDataRequest
      .statuses_that_mno_users_can_use_in_csv_uploads
      .collect do |status|
        [
          status,
          I18n.t!(
            "#{status}.description",
            scope: %i[activerecord attributes extra_mobile_data_request status],
          ),
        ]
      end
  end
end
