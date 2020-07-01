class RemoveDfeSignInIdFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :dfe_sign_in_id, :string
  end
end
