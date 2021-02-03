class ExtraMobileDataRequestSpreadsheet
  WORKSHEET_NAME = 'Extra mobile data requests'.freeze

  include ActiveModel::Model

  attr_accessor :path

  validate :spreadsheet_parseable
  validate :expected_worksheet_present, if: ->(spreadsheet) { spreadsheet.parseable? }

  def requests
    row_hashes
      .reject { |row_hash| is_example_record?(row_hash) }
      .map { |row_hash| ExtraMobileDataRequestRow.new(row_hash).build_request }
      .compact
  end

  def parseable?
    spreadsheet.present?
  end

private

  def spreadsheet_parseable
    errors.add(:base, :cannot_parse) unless parseable?
  end

  def expected_worksheet_present
    errors.add(:base, :cannot_find_expected_worksheet, worksheet_name: WORKSHEET_NAME) unless worksheet
  end

  def is_example_record?(row_hash)
    row_hash[:account_holder_name] == 'Jane Smith' && row_hash[:mobile_phone_number] == '07123456789'
  end

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
        memo[column_sym] = cleanse(row[column_index]&.value)
      end
    }.compact
  end

  def worksheet
    @worksheet ||= extract_worksheet_from_spreadsheet
  end

  def extract_worksheet_from_spreadsheet
    spreadsheet[WORKSHEET_NAME]
  end

  def spreadsheet
    RubyXL::Parser.parse(@path)
  rescue StandardError
    nil
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

  def cleanse(value)
    unless value.nil?
      value.to_s.gsub(/\n/, '').squish.strip
    end
  end
end
