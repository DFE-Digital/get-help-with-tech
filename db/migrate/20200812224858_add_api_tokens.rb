class AddApiTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :api_tokens do |t|
      t.references  :user
      t.string      :name, null: true
      t.string      :status, null: false
      t.string      :token, null: false
      t.timestamps
    end
  end
end
