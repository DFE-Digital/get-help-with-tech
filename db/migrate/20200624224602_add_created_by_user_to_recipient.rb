class AddCreatedByUserToRecipient < ActiveRecord::Migration[6.0]
  def change
    add_column :recipients, :created_by_user_id, :integer, references: :users, foreign_key: true, null: true

  end
end
