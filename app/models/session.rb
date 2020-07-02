class Session < ApplicationRecord
  def expired?
    updated_at.nil? \
    || (updated_at.utc + ttl.seconds) < Time.now.utc
  end

  def ttl
    Settings.session_ttl_seconds
  end
end
