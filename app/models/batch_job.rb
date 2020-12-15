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
      log index: index, message: "processing #{record.class.name}: #{record.id}"
      yield record
      success!(record)
    rescue Exception => e
      failure!(record: record, error: e)
    end
    report_stats
  end

private

  def success!(record)
    entry = BatchJobLogEntry.create!(
      job_name:     @job_name,
      run_id:       @run_id,
      record_id:    record.id,
      record_class: record.class.name,
      status:       'success',
    )
    @successes << entry
  end

  def failure!(record:, error:)
    BatchJobLogEntry.create!(
      job_name:     @job_name,
      run_id:       @run_id,
      record_id:    record.id,
      record_class: record.class.name,
      status:       'error',
      error:        error.message,
    )
    @failures << entry
  end

  def log(index:, message:)
    prefix = "(#{index}/#{@records.count - 1})"
    @logger.info [@job_name, @run_id, prefix, message].join(' - ')
  end
end
