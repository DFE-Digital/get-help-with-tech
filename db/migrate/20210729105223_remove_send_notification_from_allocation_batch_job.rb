class RemoveSendNotificationFromAllocationBatchJob < ActiveRecord::Migration[6.1]
  def change
    remove_column :allocation_batch_jobs, :send_notification, :boolean
  end
end
