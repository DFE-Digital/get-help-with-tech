class AddSignInTokenToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :sign_in_token, :string, null: true

    add_index :users, :sign_in_token, unique: true
  end
end
