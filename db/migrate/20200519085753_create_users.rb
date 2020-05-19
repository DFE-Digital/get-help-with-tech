class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string  :full_name
      t.string  :email_address
      t.string  :organisation
      t.string  :dfe_sign_in_id, null: true
      t.timestamps
    end

    add_index :users, :email_address
    add_index :users, :dfe_sign_in_id
  end
end
