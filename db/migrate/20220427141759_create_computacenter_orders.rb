class CreateComputacenterOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :computacenter_orders do |t|
      t.string :source
      t.integer :sold_to, index: true
      t.integer :ship_to, index: true
      t.bigint :sales_order_number
      t.string :persona
      t.integer :material_number
      t.string :material_description
      t.string :manufacturer
      t.integer :quantity_ordered
      t.integer :quantity_outstanding
      t.integer :quantity_completed
      t.date :order_date
      t.date :despatch_date
      t.boolean :order_completed
      t.boolean :is_return
      t.string :customer_order_number
      t.references :raw_order, null: false, foreign_key: { to_table: :computacenter_raw_orders }

      t.timestamps
    end
  end
end
