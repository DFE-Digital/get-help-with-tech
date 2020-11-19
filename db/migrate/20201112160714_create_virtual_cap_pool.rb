class CreateVirtualCapPool < ActiveRecord::Migration[6.0]
  def change
    create_table :virtual_cap_pools do |t|
      t.string :device_type, null: false
      t.bigint :responsible_body_id, null: false
      t.integer :cap, null: false, default: 0
      t.integer :devices_ordered, null: false, default: 0
      t.timestamps
    end

    add_foreign_key :virtual_cap_pools, :responsible_bodies, column: :responsible_body_id

    create_table :school_virtual_caps do |t|
      t.references :virtual_cap_pool, foreign_key: true
      t.references :school_device_allocation, foreign_key: true
      t.timestamps
    end
  end
end
