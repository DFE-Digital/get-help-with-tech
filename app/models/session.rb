class Session < ApplicationRecord
  DEFAULT_SESSION_TTL_SECONDS = 3600

  def expired?
    updated_at.nil? \
    || (updated_at.utc + ttl.seconds) < Time.now.utc
  end

  def ttl
    (ENV['SESSION_TTL_SECONDS'] || \
      DEFAULT_SESSION_TTL_SECONDS).to_i
  end
end
