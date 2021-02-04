class Session < ApplicationRecord
  def expired?
    expires_at < Time.zone.now.utc
  end
end
