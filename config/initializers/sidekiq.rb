ActiveJob::Base.queue_adapter = Rails.application.config.active_job.queue_adapter

redis_url = if ENV['REDIS_URL'].present?
  ENV['REDIS_URL']
elsif ENV['VCAP_SERVICES'].present?
  vcap_services ||= JSON.parse(ENV['VCAP_SERVICES'])
  redis_service_name = vcap_services.keys.find { |svc| svc =~ /redis/i }
  redis_service = vcap_services[redis_service_name].first
  redis_service['credentials']['uri']
else
  'redis://127.0.0.1:6379/'
end

Sidekiq.configure_server do |c|
  c.redis = {
    url: ENV['REDIS_URL'] || redis_url,
    db: 1
  }
end
Sidekiq.configure_client do |c|
  c.redis = {
    url: redis_url,
    db: 1
  }
end

# Make Sidekiq admin panel share the same session as the Rails  app
require 'sidekiq/web'
Sidekiq::Web.set :sessions, Rails.application.config.session_options
Sidekiq::Web.set :session_secret, Rails.application.credentials[:secret_key_base]
