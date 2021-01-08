class AddIndexesToBatchJobLogEntries < ActiveRecord::Migration[6.0]
  def change
    add_index :batch_job_log_entries, %i[job_name created_at]
    add_index :batch_job_log_entries, %i[run_id created_at]
    add_index :batch_job_log_entries, %i[run_id record_class record_id], name: 'ix_btle_run_record'
  end
end
