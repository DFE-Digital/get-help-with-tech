require 'open-uri'
require 'csv'

# TODO: find a better name / conceptual structure for this importer and others
class ImportResponsibleBodyUsersFromComputacenterCsvService
  attr_accessor :csv_uri, :successes, :failures

  def initialize(args)
    @csv_uri = args[:csv_uri]
    @successes = []
    @failures = []
  end

  def import
    csv = open(@csv_uri).read
    index = 0
    CSV.parse(csv, headers: true).select do |row|
      index += 1
      log "Importing row #{index} - #{row}"
      import_row!(row)
      @successes << row
    rescue StandardError => e
      log(e.message)
      @failures << {row: row, error: e}
    end

    log "Processed #{index} rows, of which #{failures.size} failed"
  end

private

  def log(msg)
    puts msg
  end

  def import_row!(row)
    user = build_user!(row)
    user.save!
  end

  def build_user!(row)
    rb = find_responsible_body!(row)
    User.new(
      full_name: [row['Title'], row['First Name'], row['Last Name']].compact.join(' ').strip,
      telephone: row['Telephone'],
      email_address: row['Email'],
      responsible_body: rb,
      approved_at: Time.zone.now.utc,
    )
  end

  def find_responsible_body!(row)
    # some people in the spreadsheet have multiple 'SoldTos'
    # so let's look for the default one first
    computacenter_reference = row['DefaultSoldto'].strip
    rb = ResponsibleBody.find_by_computacenter_reference(computacenter_reference)
    unless rb.present?
      log "> Couldn't find by DefaultSoldto of '#{row['DefaultSoldto']}', trying #{row['SoldTos']}"
      rb = ResponsibleBody.where('computacenter_reference IN (?)', row['SoldTos'].split(',').map(&:strip)).first
      raise ActiveRecord::RecordNotFound.new("Couldn't find a ResponsibleBody with any of these computacenter references: #{row['SoldTos']}") unless rb.present?
      log "> Found #{rb.computacenter_reference} - #{rb.name}"
    end
    rb
  end
end
