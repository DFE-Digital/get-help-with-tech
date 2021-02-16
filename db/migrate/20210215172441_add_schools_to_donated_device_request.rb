class AddSchoolsToDonatedDeviceRequest < ActiveRecord::Migration[6.1]
  def change
    add_column :donated_device_requests, :schools, :integer, array: true, default: []
    add_reference :donated_device_requests, :responsible_body, index: true
    add_column :donated_device_requests, :status, :string, null: false, default: 'incomplete'
    remove_reference :donated_device_requests, :school, null: false, index: { unique: true }
  end
end
