class CreateDonatedDeviceRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :donated_device_requests do |t|
      t.references :user, null: false, index: true
      t.references :school, null: false, index: { unique: true }
      t.text :device_types, array: true, default: []
      t.integer :units

      t.timestamps
    end
  end
end
