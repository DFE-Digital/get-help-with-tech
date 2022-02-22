class BatchJobLogEntry < ApplicationRecord
  attr_accessor :record

  def self.status(run_id:)
    { success: 0, failure: 0 }.merge(
      where(run_id:).group(:status).count.symbolize_keys,
    )
  end

  def self.latest_for_job(job_name:)
    where(job_name:).order(:created_at).last
  end

  def self.speed_stats(run_id:)
    sql = <<~SQL
      SELECT  MAX(created_at) AS max_created_at,
              MIN(created_at) AS min_created_at,
              COUNT(*) AS number_of_records
      FROM    #{table_name}
      WHERE   run_id = :run_id
    SQL
    stats = connection.select_all(sanitize_sql_for_assignment([sql, { run_id: }])).first.symbolize_keys
    stats.merge({
      duration: stats[:max_created_at] - stats[:min_created_at],
      records_per_second: (stats[:number_of_records] / (stats[:max_created_at] - stats[:min_created_at])),
      time_per_record: (stats[:max_created_at] - stats[:min_created_at]) / stats[:number_of_records],
    })
  end
end
