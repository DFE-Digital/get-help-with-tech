require 'open-uri'
require 'csv'

class ImportLocalAuthorityGiasIdsService
  attr_accessor :csv_uri, :successes, :failures

  def initialize(csv_uri:)
    @csv_uri = csv_uri
    @successes = []
    @failures = []
  end

  def import
    csv = URI.open(@csv_uri).read
    index = 0
    CSV.parse(csv, headers: true).select do |row|
      index += 1
      import_row(row)
      @successes << row
    rescue StandardError => e
      @failures << { row: row, error: e }
    end
    Rails.logger.info "Processed #{index} rows, #{@successes.size} successes, #{@failures.size} failures"
  end

  def import_row(row)
    la = LocalAuthority.find_by_local_authority_eng!(row['Local Authority ENG'])
    Rails.logger.info "updating #{la.name} with GIAS ID #{row['Local Authority GIAS ID']}"
    la.update!(gias_id: row['Local Authority GIAS ID'])
  end
end
