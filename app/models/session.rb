class Session < ApplicationRecord
  def expired?
    updated_at.nil? \
    || (updated_at.utc + ttl.seconds) < Time.zone.now.utc
  end

  # def expired?
  #   expires_at < Time.zone.now.utc
  # end

  def ttl
    Settings.session_ttl_seconds
  end
end
