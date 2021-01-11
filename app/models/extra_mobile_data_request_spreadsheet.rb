class ExtraMobileDataRequestSpreadsheet
  WORKSHEET_NAME = 'Extra mobile data requests'.freeze

  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
  end

  def requests
    row_hashes.map do |row_hash|
      ExtraMobileDataRequestRow.new(row_hash).build_request
    end
  end

private

  # Returns a collection of hashes mapping column name symbols to values:
  #
  # [
  #   { account_holder_name: 'Jane Smith', mobile_phone_number: '07123456789', ... },
  #   { account_holder_name: 'John Smith', mobile_phone_number: '07987654321', ... },
  # ]
  def row_hashes
    header_row = worksheet.sheet_data.rows[0]
    header_hash = header_name_to_column_mapping(header_row)

    worksheet.map.with_index { |row, n|
      next if n.zero? || row.nil? # skip the header row

      header_hash.keys.each_with_object({}) do |column_sym, memo|
        column_index = header_hash[column_sym]
        memo[column_sym] = row[column_index]&.value
      end
    }.compact
  end

  def worksheet
    @worksheet ||= extract_worksheet_from_spreadsheet
  end

  def extract_worksheet_from_spreadsheet
    RubyXL::Parser.parse(@spreadsheet_path)[WORKSHEET_NAME]
  end

  # Returns a hash mapping the header column names (as symbols) to their column index
  #
  #   { account_holder_name: 0, mobile_phone_number: 1, ... },
  def header_name_to_column_mapping(header_row)
    header_row.cells.each_with_object({}) do |cell, memo|
      if cell&.value
        column_heading = cell.value.to_s.parameterize(separator: '_')
        memo[column_heading.to_sym] = cell.column
      end
    end
  end
end
