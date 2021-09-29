class CreateAllocationChanges < ActiveRecord::Migration[6.1]
  def change
    create_table :allocation_changes do |t|
      t.references :school_device_allocation, null: false, foreign_key: true
      t.string :category
      t.integer :delta
      t.integer :prev_allocation
      t.integer :new_allocation
      t.text :description

      t.timestamps
    end
    add_index :allocation_changes, :category
  end
end
