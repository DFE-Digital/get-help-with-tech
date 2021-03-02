class Session < ApplicationRecord
  has_one :support_ticket, dependent: :destroy

  def expired?
    expires_at < Time.zone.now.utc
  end
end
