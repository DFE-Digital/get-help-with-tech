class AddCompletedAtToDonatedDevices < ActiveRecord::Migration[6.1]
  def change
    add_column :donated_device_requests, :completed_at, :datetime, null: true
    add_index :donated_device_requests, :completed_at
  end
end
