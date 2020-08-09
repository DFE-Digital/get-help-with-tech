class ExtraDataRequestSpreadsheetImporter
  attr_reader :summary

  def initialize
    @summary = BulkUploadSummary.new
  end

  def import!(spreadsheet_path, user)
    workbook = RubyXL::Parser.parse(spreadsheet_path)
    worksheet = workbook['Extra mobile data requests']

    worksheet.each_with_index do |row, n|
      next if n.zero? || row.nil? # skip the header row

      request_attrs = fetch_request_attrs(row)

      next unless request_attrs

      extra_mobile_data_request = create_request(request_attrs, user)

      if extra_mobile_data_request.valid?
        if request_already_exists?(extra_mobile_data_request)
          summary.add_existing_record(extra_mobile_data_request)
        else
          extra_mobile_data_request.save_and_notify_account_holder!
          summary.add_successful_record(extra_mobile_data_request)
        end
      else
        summary.add_error_record(extra_mobile_data_request)
      end
    end
    summary
  end

private

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

  def create_request(request_attrs, user)
    ExtraMobileDataRequest.new(
      request_attrs.merge(created_by_user: user),
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
