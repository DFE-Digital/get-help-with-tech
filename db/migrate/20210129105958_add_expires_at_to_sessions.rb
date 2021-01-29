class AddExpiresAtToSessions < ActiveRecord::Migration[6.1]
  def change
    add_column :sessions, :expires_at, :datetime
  end
end
