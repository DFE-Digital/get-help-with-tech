class RemoveUsersApprovedAtTimestamp < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :approved_at, :datetime
  end
end
