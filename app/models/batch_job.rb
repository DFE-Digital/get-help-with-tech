class BatchJob
  attr_accessor :successes, :failures
  attr_accessor :records
  attr_accessor :run_id, :job_name, :logger

  def initialize(records:, job_name:, logger: nil)
    @records = records
    @job_name = job_name
    @logger = logger || Rails.logger
  end

  # call this with a block, to which each record will be yielded
  def process!
    new_run!
    @records.each_with_index do |record, index|
      log index: index, message: "processing #{record.class.name}: #{record_id(record)}"
      yield record
      success!(record)
    rescue Exception => e
      failure!(record: record, error: e)
    end
    job_stats
  end

  def job_stats
    BatchJobLogEntry.status(run_id: @run_id).merge( BatchJobLogEntry.speed_stats(run_id: @run_id) )
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
    entry = create_job_log_entry(record: record, status: 'success')
    @successes << entry
  end

  def failure!(record:, error:)
    entry = create_job_log_entry(record: record, status: 'failure', error: error)
    @failures << entry
  end

  def create_job_log_entry(record:, status:, error: nil)
    BatchJobLogEntry.create!(
      job_name:     @job_name,
      run_id:       @run_id,
      record_id:    record_id(record),
      record_class: record.class.name,
      status:       status,
      error:        error&.message,
    )
  end

  def log(index:, message:)
    prefix = "(#{index}/#{@records.count - 1})"
    @logger.info [@job_name, @run_id, prefix, message].join(' - ')
  end
end
