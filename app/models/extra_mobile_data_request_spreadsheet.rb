class ExtraMobileDataRequestSpreadsheet
  WORKSHEET_NAME = 'Extra mobile data requests'.freeze

  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
  end

  def requests
    map_header_row

    worksheet.map.with_index { |row, n|
      next if n.zero? || row.nil? # skip the header row

      row_hash = @headers.keys.inject({}) do |memo, column_sym|
        column_index = @headers[column_sym]
        memo[column_sym] = row[column_index]&.value
        memo
      end
      ExtraMobileDataRequestRow.new(row_hash).build_request
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
end
