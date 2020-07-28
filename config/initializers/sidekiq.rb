Rails.application.config.active_job.queue_adapter = :sidekiq
redis_protocol = $redis_config[:ssl] ? 'rediss' : 'redis'
if $redis_config[:password]
  redis_url = "#{redis_protocol}://:#{$redis_config[:password]}@#{$redis_config[:host]}:#{$redis_config[:port]}/0"
else
  redis_url = "#{redis_protocol}://#{$redis_config[:host]}:#{$redis_config[:port]}/0"
end

Rails.logger.info "Configuring sidekiq with redis_url: #{redis_url}"
Sidekiq.configure_server do |c|
  c.redis = {
    url: ENV['REDIS_URL'] || redis_url,
    namespace: 'sidekiq'
  }
end

Rails.logger.info "Sidekiq configured OK"

# Make Sidekiq admin panel share the same session as the Rails  app
require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.credentials[:secret_key_base]
