Rails.application.config.active_job.queue_adapter = :sidekiq

Sidekiq.configure_server { |c| c.redis = { url: ENV['REDIS_URL'] } }

# Make Sidekiq admin panel share the same session as the Rails  app
require 'sidekiq/web'
# Sidekiq::Web.set :sessions, false
Sidekiq::Web.set :session_secret, Rails.application.credentials[:secret_key_base]
