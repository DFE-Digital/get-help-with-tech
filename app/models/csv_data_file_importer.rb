class CsvDataFileImporter
  attr_accessor :csv_data_file, :logger, :failures, :successes

  def initialize(csv_data_file:, logger: Rails.logger)
    @csv_data_file = csv_data_file
    @logger = logger
    @failures = []
    @successes = []
  end

  def import!
    index = 0
    @csv_data_file.send(:records) do |record|
      index += 1
      log "Importing row #{index} - #{record}"
      @csv_data_file.import_record!(record)
      @successes << record
    rescue StandardError => e
      log(e.message)
      @failures << { record:, error: e }
    end

    log "Processed #{index} rows, of which #{failures.size} failed"
  end

private

  def log(msg)
    @logger.info msg
  end
end
