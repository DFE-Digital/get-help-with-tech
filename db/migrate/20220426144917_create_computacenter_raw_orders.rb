class CreateComputacenterRawOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :computacenter_raw_orders do |t|
      t.string :source
      t.string :responsible_body
      t.string :urn_cc
      t.string :category
      t.string :sold_to_account_no
      t.string :sold_to_customer
      t.string :ship_to_urn
      t.string :ship_to_account_no
      t.string :ship_to_customer
      t.string :sales_order_number
      t.string :persona_cleaned
      t.string :material_number
      t.string :material_description
      t.string :manufacturer_cleaned
      t.string :quantity_ordered
      t.string :quantity_outstanding
      t.string :quantity_completed
      t.string :order_date
      t.string :despatch_date
      t.string :order_completed
      t.string :is_return
      t.string :customer_order_number
      t.datetime :processed_at

      t.timestamps
    end
  end
end
