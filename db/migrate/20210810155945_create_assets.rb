class CreateAssets < ActiveRecord::Migration[6.1]
  def change
    create_table :assets do |t|
      t.string :tag
      t.string :serial_number, null: false
      t.string :model
      t.string :department
      t.string :department_id
      t.string :department_sold_to_id
      t.string :location
      t.string :location_id
      t.string :location_cc_ship_to_account
      t.string :encrypted_bios_password
      t.string :encrypted_admin_password
      t.string :encrypted_hardware_hash
      t.datetime :sys_created_at
      t.datetime :first_viewed_at

      t.timestamps
    end
    add_index :assets, :serial_number
    add_index :assets, :department_sold_to_id
    add_index :assets, :location_cc_ship_to_account
  end
end
