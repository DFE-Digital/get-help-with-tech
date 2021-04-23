# This line should not be necessary, but it is - without this, on CloudFoundry
# the ActiveJob::Base.queue_adapter seems to be :async, no matter what we set
# the config.active_job.queue_adapter to.
ActiveJob::Base.queue_adapter = Rails.application.config.active_job.queue_adapter

redis_url = if ENV['REDIS_URL'].present?
              ENV['REDIS_URL']
            elsif ENV['VCAP_SERVICES'].present?
              require 'v_cap_services_config'
              redis_config = VCapServicesConfig.new.first_service_matching('redis')
              redis_config['credentials']['uri']
            else
              'redis://127.0.0.1:6379/'
            end

Sidekiq.configure_server do |c|
  c.redis = {
    url: redis_url,
    db: 1,
  }
end
Sidekiq.configure_client do |c|
  c.redis = {
    url: redis_url,
    db: 1,
  }
end

# Make Sidekiq admin panel share the same session as the Rails  app
require 'sidekiq/web'
require 'sidekiq-scheduler/web'
