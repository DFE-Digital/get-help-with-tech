class AddPrivacyNoticeSeenAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :privacy_notice_seen_at, :timestamp
  end
end
