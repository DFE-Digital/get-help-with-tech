class ExtraMobileDataRequestSpreadsheet
  DEFAULT_COLUMN_POSITIONS = {
    account_holder_name: 0,
    mobile_phone_number: 1,
    mobile_network: 2,
    pay_monthly_or_payg: 3,
    has_someone_shared_the_privacy_statement_with_the_account_holder: 4,
  }.freeze

  WORKSHEET_NAME = 'Extra mobile data requests'.freeze

  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
  end

  def requests
    map_header_row

    worksheet.map.with_index { |row, n|
      next if n.zero? || row.nil? # skip the header row

      build_request(row)
    }.compact
  end

private

  def worksheet
    @worksheet ||= extract_worksheet_from_spreadsheet
  end

  def extract_worksheet_from_spreadsheet
    RubyXL::Parser.parse(@spreadsheet_path)[WORKSHEET_NAME]
  end

  def map_header_row
    @headers = {}
    row = worksheet.sheet_data.rows[0]
    row.cells.each_with_index do |c, i|
      if c&.value
        column_heading = c.value.to_s.parameterize(separator: '_')
        @headers[column_heading.to_sym] = i
      end
    end
  end

  def build_request(row)
    @current_row = row

    request_attrs = fetch_request_attrs

    ExtraMobileDataRequest.new(request_attrs) if request_attrs
  end

  def fetch_request_attrs
    attrs = {
      account_holder_name: account_holder_name,
      device_phone_number: mobile_phone_number,
      mobile_network_id: mobile_network_id,
      contract_type: contract_type,
      agrees_with_privacy_statement: agrees_with_privacy_statement,
    }
    return attrs unless attrs.values.all?(&:nil?)
  end

  def account_holder_name
    column_value(:account_holder_name)
  end

  def mobile_phone_number
    column_value(:mobile_phone_number)
  end

  def mobile_network_id
    network_name = column_value(:mobile_network)
    MobileNetwork.find_by(brand: network_name)&.id
  end

  def contract_type
    contract_type = column_value(:pay_monthly_or_payg)
    contract_type.parameterize.gsub('-', '_') if contract_type
  end

  def agrees_with_privacy_statement
    column_value(:has_someone_shared_the_privacy_statement_with_the_account_holder)
  end

  def column_value(name)
    column_name = name.to_sym
    index = @headers[column_name] || DEFAULT_COLUMN_NAMES[column_name]
    @current_row[index]&.value
  end
end
