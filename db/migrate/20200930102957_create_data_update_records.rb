class CreateDataUpdateRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :data_update_records do |t|
      t.string :name, null: false
      t.datetime :staged_at
      t.datetime :updated_records_at
      t.timestamps
    end
    add_index :data_update_records, :name, unique: true
  end
end
