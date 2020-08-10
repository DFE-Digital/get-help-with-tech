class ExtraMobileDataRequestSpreadsheet

  class SpreadsheetRow
    DEFAULT_COLUMN_POSITIONS = {
      account_holder_name: 0,
      mobile_phone_number: 1,
      mobile_network: 2,
      pay_monthly_or_payg: 3,
      has_someone_shared_the_privacy_statement_with_the_account_holder: 4,
    }

    def initialize(row)
      @row = row
    end

    def column(name)
      name = name.to_sym
      index = @@headers[name] || DEFAULT_COLUMN_NAMES[name]
      @row[index]&.value
    end

    def self.set_headers(header_row)
      @@headers = {}
      header_row.cells.each_with_index do |c, i|
        @@headers[heading_to_sym(c.value)] = i if c&.value
      end
    end

  private
    def self.heading_to_sym(val)
      val.to_s.parameterize(separator: '_').to_sym
    end

    def fetch_column_value(name)
      index = headers[name] || DEFAULT_COLUMN_NAMES[name]
      row[index]&.value
    end
  end

  WORKSHEET_NAME = 'Extra mobile data requests'


  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
  end

  def requests
    workbook = RubyXL::Parser.parse(@spreadsheet_path)
    worksheet = workbook[WORKSHEET_NAME]

    SpreadsheetRow.set_headers(worksheet.sheet_data.rows[0])

    worksheet.map.with_index { |row, n|
      next if n.zero? || row.nil? # skip the header row

      request_attrs = fetch_request_attrs(SpreadsheetRow.new(row))

      ExtraMobileDataRequest.new(request_attrs) if request_attrs
    }.compact
  end

private
  def fetch_request_attrs(row)
    attrs = {
      account_holder_name: row.column(:account_holder_name),
      device_phone_number: row.column(:mobile_phone_number),
      mobile_network_id: lookup_network(row.column(:mobile_network)),
      contract_type: row.column(:pay_monthly_or_payg)&.parameterize,
      agrees_with_privacy_statement: row.column(:has_someone_shared_the_privacy_statement_with_the_account_holder),
    }
    return attrs unless attrs.values.all?(&:nil?)
  end

  def lookup_network(network_name)
    MobileNetwork.find_by(brand: network_name)&.id
  end
end
