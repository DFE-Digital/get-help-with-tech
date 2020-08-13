class AddAPITokens < ActiveRecord::Migration[6.0]
  def change
    create_table :api_tokens do |t|
      t.references  :user
      t.string      :name, null: true
      t.string      :status, null: false
      t.string      :token, null: false
      t.timestamps
    end

    add_index :api_tokens, %i[user_id name], unique: true
    add_index :api_tokens, %i[user_id token], unique: true
  end
end
