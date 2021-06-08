Rails.application.reloader.to_prepare do
  Rails.application.config.session_store :cookie_store, expire_after: SessionService::TTLS.max
end
