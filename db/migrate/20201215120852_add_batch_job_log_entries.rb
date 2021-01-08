class AddBatchJobLogEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :batch_job_log_entries do |t|
      t.string    :record_id
      t.string    :record_class
      t.string    :job_name
      t.string    :run_id
      t.string    :status
      t.string    :message
      t.string    :error
      t.timestamps
    end
  end
end
