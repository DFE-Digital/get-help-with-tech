class AddUserApprovedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :approved_at, :datetime, null: true

    add_index :users, :approved_at
  end
end
