require 'csv'
require 'open-uri'

class CsvDataFile
  def initialize(csv_uri)
    @csv_uri = csv_uri
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
    csv = download_to_temp_file_if_needed(@csv_uri)
    CSV.foreach(csv, headers: true) do |row|
      next if skip?(row)

      yield row
    end
  end

  def download_to_temp_file_if_needed(uri)
    is_remote?(uri) ? download_to_temp_file(uri) : uri
  end

  def is_remote?(uri)
    %w[http https].include?(URI.parse(uri.to_s).scheme)
  end

  def download_to_temp_file(uri)
    tempfile = Tempfile.new
    RemoteFile.download(uri, tempfile)
    tempfile.path
  end
end
