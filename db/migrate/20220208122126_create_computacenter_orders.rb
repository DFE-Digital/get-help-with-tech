class CreateComputacenterOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :computacenter_orders do |t|
      t.string :raw_customer_order_number
      t.string :raw_delivery_date
      t.string :raw_despatch_date
      t.string :raw_is_return
      t.string :raw_manufacturer_name
      t.string :raw_material_description
      t.string :raw_material_number
      t.string :raw_order_completed
      t.string :raw_order_date
      t.string :raw_order_days_to_delivery
      t.string :raw_order_days_to_despatch
      t.string :raw_persona
      t.string :raw_persona_description
      t.string :raw_quantity_completed
      t.string :raw_quantity_ordered
      t.string :raw_quantity_outstanding
      t.string :raw_sales_order_number
      t.string :raw_school_urn
      t.string :raw_ship_to_account_no
      t.string :raw_ship_to_customer
      t.string :raw_sold_to_account_no
      t.string :raw_sold_to_customer
      t.string :raw_urn_cc

      # raw fields with a flag for data exceptions
      t.string :raw_school_urn_flag

      # dates
      t.date :delivery_date
      t.date :despatch_date
      t.date :order_date

      # booleans
      t.boolean :is_return
      t.boolean :order_completed

      # integers
      t.integer :school_urn
      t.integer :order_days_to_delivery
      t.integer :order_days_to_despatch
      t.integer :quantity_completed
      t.integer :quantity_ordered
      t.integer :quantity_outstanding

      # strings - extra fields
      t.string :provision_urn

      t.timestamps
    end

    # things we are likely to query with
    add_index :computacenter_orders, :raw_customer_order_number
    add_index :computacenter_orders, :raw_ship_to_account_no
    add_index :computacenter_orders, :raw_sold_to_account_no
    add_index :computacenter_orders, :raw_school_urn_flag
    add_index :computacenter_orders, :school_urn
    add_index :computacenter_orders, :provision_urn
  end
end
