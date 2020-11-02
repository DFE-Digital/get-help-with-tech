class AddDeletedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :deleted_at, :datetime, null: true, default: nil
    add_index :users, :deleted_at
  end
end
