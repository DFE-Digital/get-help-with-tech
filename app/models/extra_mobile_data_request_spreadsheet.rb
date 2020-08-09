class ExtraMobileDataRequestSpreadsheet
  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
  end

  def requests
    workbook = RubyXL::Parser.parse(@spreadsheet_path)
    worksheet = workbook['Extra mobile data requests']

    worksheet.map.with_index { |row, n|
      next if n.zero? || row.nil? # skip the header row

      request_attrs = fetch_request_attrs(row)

      ExtraMobileDataRequest.new(request_attrs) if request_attrs
    }.compact
  end

private

  def fetch_request_attrs(row)
    attrs = {
      account_holder_name: row[0]&.value,
      device_phone_number: row[1]&.value,
      mobile_network: lookup_network(row[2]&.value),
      agrees_with_privacy_statement: row[4]&.value,
    }
    return attrs unless attrs.values.all?(&:nil?)
  end

  def lookup_network(network_name)
    MobileNetwork.find_by(brand: network_name)
  end
end
