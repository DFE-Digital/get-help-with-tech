class CreateBTWifiVouchers < ActiveRecord::Migration[6.0]
  def change
    create_table :bt_wifi_vouchers do |t|
      t.string :username, null: false
      t.string :password, null: false
      t.integer :responsible_body_id
      t.timestamp :distributed_at

      t.timestamps
    end

    add_foreign_key :bt_wifi_vouchers, :responsible_bodies, column: :responsible_body_id
  end
end
