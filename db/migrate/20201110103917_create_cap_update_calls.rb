class CreateCapUpdateCalls < ActiveRecord::Migration[6.0]
  def change
    create_table :cap_update_calls do |t|
      t.references :school_device_allocation
      t.text :request_body
      t.text :response_body

      t.timestamps
    end
  end
end
