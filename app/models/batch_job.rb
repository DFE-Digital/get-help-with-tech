class BatchJob
  attr_accessor :successes, :failures, :records, :run_id, :job_name, :logger

  def initialize(records:, job_name:, logger: Rails.logger)
    @records = records
    @job_name = job_name
    @logger = logger
    new_run!
  end

  # call this with a block, to which each record will be yielded
  def process!
    @records.each_with_index do |record, index|
      log index: index, message: "processing #{record.class.name}: #{record_id(record)}"
      yield record
      success!(record)
    rescue StandardError => e
      failure!(record: record, error: e)
    end
    stats
  end

  def stats
    self.class.stats(run_id: @run_id)
  end

  def self.stats(run_id:)
    BatchJobLogEntry.status(run_id: run_id).merge(BatchJobLogEntry.speed_stats(run_id: run_id))
  end

private

  def new_run!
    @run_id = SecureRandom.uuid
    @successes = []
    @failures = []
  end

  def record_id(record)
    record.respond_to?(:id) ? record.id : record.to_s.first(100)
  end

  def success!(record)
    entry = find_or_create_job_log_entry!(record: record, status: 'success')
    entry.record = record
    @successes << entry
  end

  def failure!(record:, error:)
    entry = find_or_create_job_log_entry!(record: record, status: 'failure', error: error)
    entry.record = record
    @failures << entry
  end

  def find_or_create_job_log_entry!(record:, status:, error: nil)
    entry = BatchJobLogEntry.find_or_create_by!(
      job_name: @job_name,
      run_id: @run_id,
      record_id: record_id(record),
      record_class: record.class.name,
    )
    entry.update!(
      status: status,
      error: error&.message,
    )
    entry
  end

  def log(index:, message:)
    prefix = "(#{index}/#{@records.count - 1})"
    @logger.info [@job_name, @run_id, prefix, message].join(' - ')
  end
end
