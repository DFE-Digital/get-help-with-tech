class SetNullStatusToRequested < ActiveRecord::Migration[6.0]
  def change
    Recipient.where(status: nil).update_all(status: Recipient.statuses[:requested])
  end
end
