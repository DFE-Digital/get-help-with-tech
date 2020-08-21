class AddPreorderInformation < ActiveRecord::Migration[6.0]
  def change
    create_table :preorder_information do |t|
      t.references :school, null: false
      t.string :who_will_order_devices, null: false
      t.timestamps
    end
  end
end
