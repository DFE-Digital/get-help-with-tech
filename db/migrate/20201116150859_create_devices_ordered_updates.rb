class CreateDevicesOrderedUpdates < ActiveRecord::Migration[6.0]
  def change
    create_table :computacenter_devices_ordered_updates do |t|
      t.string :cap_type
      t.string :ship_to
      t.integer :cap_amount
      t.integer :cap_used

      t.timestamps
    end

    add_index :computacenter_devices_ordered_updates, :ship_to
  end
end
