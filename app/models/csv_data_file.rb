require 'csv'

class CsvDataFile
  def initialize(csv_path)
    @csv_path = csv_path
  end

protected

  def records
    all_records = []

    read_file do |row|
      record = extract_record(row)

      if block_given?
        yield record
      else
        all_records << record
      end
    end
    all_records unless block_given?
  end

  def extract_record(row)
    # override me
    row
  end

  def skip?(_row)
    # override me
    false
  end

private

  def read_file
    CSV.foreach(@csv_path, headers: true, encoding: 'ISO8859-1:utf-8') do |row|
      next if skip?(row)

      yield row
    end
  end
end
