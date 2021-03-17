class CreateRemainingDeviceCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :remaining_device_counts do |t|
      t.datetime :date_of_count, null: false, index: true
      t.integer :remaining_from_devolved_schools, null: false
      t.integer :remaining_from_managed_schools, null: false
      t.integer :total_remaining, null: false
      t.timestamps
    end
  end
end
