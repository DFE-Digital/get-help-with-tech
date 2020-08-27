require 'open-uri'
require 'csv'

class ImportComputacenterReferencesService
  attr_accessor :csv_uri, :logger, :failures, :successes

  def initialize(csv_uri:, logger: Rails.logger)
    @csv_uri = csv_uri
    @logger = logger
    @failures = []
    @successes = []
  end

  def import
    csv = URI.open(@csv_uri).read
    index = 0
    CSV.parse(csv, headers: true).select do |row|
      index += 1
      log "Importing row #{index} - #{row}"
      import_row!(row)
      @successes << row
    rescue StandardError => e
      log(e.message)
      @failures << { row: row, error: e }
    end

    log "Processed #{index} rows, of which #{failures.size} failed"
  end

  def import_row!(row)
    rb = find_responsible_body!(row['Responsible Body URN'])
    log "> RB given URN: #{row['Responsible Body URN']}, found ENG: #{rb.local_authority_eng}"
    rb.update!(computacenter_reference: row['Sold To Number'])
    log ">> computacenter_reference: #{rb.computacenter_reference}"
    school = find_school!(row['School URN + School Name'])
    log "School given URN: #{row['School URN + School Name']}, found URN: #{school.urn}"
    school.update!(computacenter_reference: row['Ship To Number'])
    log ">> computacenter_reference: #{school.computacenter_reference}"
  end

private

  def log(msg)
    @logger.info msg
  end

  def find_school!(cc_urn_and_name)
    School.find_by_urn!(cc_urn_and_name.split(' ').first)
  end

  def find_responsible_body!(cc_urn)
    ResponsibleBody.find_by_computacenter_urn!(cc_urn)
  end
end
