Rails.application.config.session_store :cookie_store, expire_after: Settings.session_ttl_seconds.seconds
