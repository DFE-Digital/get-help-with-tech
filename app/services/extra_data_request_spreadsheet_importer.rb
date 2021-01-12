class ExtraDataRequestSpreadsheetImporter
  attr_reader :summary

  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
    @summary = BulkUploadSummary.new
  end

  def spreadsheet
    @spreadsheet ||= ExtraMobileDataRequestSpreadsheet.new(@spreadsheet_path)
  end

  def import!(extra_fields: {})
    spreadsheet.requests.each do |extra_mobile_data_request|
      extra_mobile_data_request.assign_attributes(extra_fields)

      if extra_mobile_data_request.invalid?
        summary.add_error_record(extra_mobile_data_request)
      elsif extra_mobile_data_request.has_already_been_made?
        summary.add_existing_record(extra_mobile_data_request)
      else
        extra_mobile_data_request.save_and_notify_account_holder!
        summary.add_successful_record(extra_mobile_data_request)
      end
    end
    summary
  end
end
