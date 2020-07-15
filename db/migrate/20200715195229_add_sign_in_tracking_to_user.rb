class AddSignInTrackingToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :sign_in_count, :integer, default: 0
    add_column :users, :last_signed_in_at, :timestamp
  end
end
