class CreateCapUsageUpdatePayload < ActiveRecord::Migration[6.1]
  def change
    create_table :computacenter_cap_usage_update_payloads do |t|
      t.string :payload_id
      t.string :payload_xml
      t.datetime :payload_timestamp
      t.integer :records_count
      t.integer :succeeded_count
      t.integer :failed_count
      t.string :status
      t.datetime :completed_at

      t.timestamps
    end
    add_index :computacenter_cap_usage_update_payloads, :payload_id
  end
end
