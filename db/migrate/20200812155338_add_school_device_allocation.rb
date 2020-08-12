class AddSchoolDeviceAllocation < ActiveRecord::Migration[6.0]
  def change
    create_table :school_device_allocations do |t|
      t.references  :schools, foreign_key: true
      t.string      :device_type, null: false
      t.integer     :allocation, default: 0
      t.integer     :devices_ordered, default: 0
      t.bigint      :created_by_user_id, null: true, foreign_key: true
      t.bigint      :last_updated_by_user_id, null: true, foreign_key: true
      t.timestamps
    end
  end
end
