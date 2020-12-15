class BatchJob
  attr_accessor :successes, :failures
  attr_accessor :records
  attr_accessor :run_id, :job_name, :logger

  def initialize(records:, job_name:, logger: nil)
    @records = records
    @job_name = job_name
    @logger = logger || Rails.logger
  end

  def process!(&block)
    @run_id = SecureRandom.uuid
    @successes = []
    @failures = []
    @records.each_with_index do |record, index|
      log index: index, message: "processing #{record.class.name}: #{record_id(record)}"
      yield record
      success!(record)
    rescue Exception => e
      failure!(record: record, error: e)
    end
    report_stats
  end

  def report_stats
    puts BatchJobLogEntry.status(run_id: @run_id)
    puts BatchJobLogEntry.speed_stats(run_id: @run_id)
  end

private
  def record_id(record)
    record.respond_to?(:id) ? record.id : record.to_s.first(100)
  end

  def success!(record)
    entry = BatchJobLogEntry.create!(
      job_name:     @job_name,
      run_id:       @run_id,
      record_id:    record_id(record),
      record_class: record.class.name,
      status:       'success',
    )
    @successes << entry
  end

  def failure!(record:, error:)
    entry = BatchJobLogEntry.create!(
      job_name:     @job_name,
      run_id:       @run_id,
      record_id:    record_id(record),
      record_class: record.class.name,
      status:       'failure',
      error:        error.message,
    )
    @failures << entry
  end

  def log(index:, message:)
    prefix = "(#{index}/#{@records.count - 1})"
    @logger.info [@job_name, @run_id, prefix, message].join(' - ')
  end
end
