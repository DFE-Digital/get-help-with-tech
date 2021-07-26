class CreateSupplierOutages < ActiveRecord::Migration[6.1]
  def change
    create_table :supplier_outages do |t|
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
