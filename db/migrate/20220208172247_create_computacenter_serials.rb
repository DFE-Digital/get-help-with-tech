class CreateComputacenterSerials < ActiveRecord::Migration[6.1]
  def change
    create_table :computacenter_serials do |t|
      t.string :raw_customer_order_date
      t.string :raw_customer_order_number
      t.string :raw_delivery_number
      t.string :raw_despatch_date
      t.string :raw_manufacturer_name
      t.string :raw_manufacturer_part_number
      t.string :raw_material_description
      t.string :raw_material_number
      t.string :raw_order_date
      t.string :raw_order_number
      t.string :raw_order_position
      t.string :raw_part_classification_desc
      t.string :raw_persona
      t.string :raw_persona_description
      t.string :raw_report_quantity
      t.string :raw_school_urn
      t.string :raw_serial_number
      t.string :raw_ship_to_account_no
      t.string :raw_ship_to_address
      t.string :raw_ship_to_customer
      t.string :raw_ship_to_post_code
      t.string :raw_ship_to_town
      t.string :raw_sold_to_account_no
      t.string :raw_sold_to_customer
      t.string :raw_urn

      # raw fields with a flag for data exceptions
      t.string :raw_school_urn_flag

      # dates
      t.date :customer_order_date
      t.date :despatch_date
      t.date :order_date

      # integers
      t.integer :school_urn

      # strings - extra fields
      t.string :provision_urn

      t.timestamps
    end

    # things we are likely to query with
    add_index :computacenter_serials, :raw_customer_order_number
    add_index :computacenter_serials, :raw_ship_to_account_no
    add_index :computacenter_serials, :raw_sold_to_account_no
    add_index :computacenter_serials, :raw_school_urn_flag
    add_index :computacenter_serials, :school_urn
    add_index :computacenter_serials, :provision_urn
  end
end
