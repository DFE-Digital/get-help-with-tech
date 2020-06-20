class AddSignInTokenExpiresAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :sign_in_token_expires_at, :datetime, null: true
  end
end
