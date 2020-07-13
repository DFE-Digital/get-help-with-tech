class CreateBTWifiVoucherAllocations < ActiveRecord::Migration[6.0]
  def change
    create_table :bt_wifi_voucher_allocations do |t|
      t.integer :responsible_body_id, null: false
      t.integer :amount, null: false

      t.timestamps
    end

    add_foreign_key :bt_wifi_voucher_allocations, :responsible_bodies
  end
end
