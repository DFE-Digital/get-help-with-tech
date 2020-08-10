class ExtraDataRequestSpreadsheetImporter
  attr_reader :summary

  def initialize
    @summary = BulkUploadSummary.new
  end

  def import!(spreadsheet_path, user)
    spreadsheet = ExtraMobileDataRequestSpreadsheet.new(spreadsheet_path)

    spreadsheet.requests.each do |extra_mobile_data_request|
      extra_mobile_data_request.created_by_user = user

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

private

  def navigate_worksheet(&block)
  end

  def headers
    @headers ||= capture_headers
  end

  def capture_headers
    headers = {}
    row = @worksheet.sheet_data.rows[0]
    row.cols.each_with_index do |c, i|
      headers[make_sym(c.value)] = i if c&.value
    end
    headers
  end

  def make_sym(val)
    val.to_s.parameterize(separator: '_').to_sym
  end

  def fetch_request_attrs(row)
    attrs = {
      account_holder_name: row[0]&.value,
      device_phone_number: row[1]&.value,
      mobile_network_id: lookup_network_id(row[2]&.value),
      agrees_with_privacy_statement: row[4]&.value,
    }
    return attrs unless attrs.values.all?(&:nil?)
  end

  def lookup_network_id(network_name)
    MobileNetwork.find_by(brand: network_name)&.id
  end

  def build_request(request_attrs, user)
    ExtraMobileDataRequest.new(
      request_attrs.merge({
        created_by_user: user,
        status: :requested,
      }),
    )
  end

  def request_already_exists?(request)
    ExtraMobileDataRequest.exists?(
      account_holder_name: request.account_holder_name,
      device_phone_number: request.device_phone_number,
      mobile_network_id: request.mobile_network_id,
    )
  end
end
