class DisallowNullRecipientStatus < ActiveRecord::Migration[6.0]
  def change
    Recipient.where(status: nil).update_all(status: Recipient.statuses[:requested])
    change_column :recipients, :status, :string, null: false
  end
end
