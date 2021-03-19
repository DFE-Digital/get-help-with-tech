require 'rack/throttle'
# This line is a little odd, but prevents a deprecation warning on startup
# about autoloading constants during initialization
require_relative '../../app/services/feature_flag'

class RackThrottleConfig
  RULES = [
    { method: 'POST', limit: Integer(Settings.throttling.limits.post) },
    { method: 'PUT', limit: Integer(Settings.throttling.limits.put) },
    { method: 'PATCH', limit: Integer(Settings.throttling.limits.patch) },
    { method: 'DELETE', limit: Integer(Settings.throttling.limits.delete) },
    { method: 'GET', limit: Integer(Settings.throttling.limits.get) },
    { method: 'GET', path: '/token/.*', limit: Integer(Settings.throttling.limits['/token'].get) },
    { method: 'GET', path: '/sign-in/.*', limit: Integer(Settings.throttling.limits['/sign-in'].get) },
    { method: 'POST', path: '/sign-in/.*', limit: Integer(Settings.throttling.limits['/sign-in'].post) },
  ].freeze
  DEFAULT = Settings.throttling.default_limit

  def self.redis_url
    if ENV['REDIS_URL'].present?
      ENV['REDIS_URL']
    elsif ENV['VCAP_SERVICES'].present?
      require 'v_cap_services_config'
      redis_config = VCapServicesConfig.new.first_service_matching('redis')
      redis_config['credentials']['uri']
    end
  end
end

# only do this if enabled, so that we don't throttle features specs, for instance
if FeatureFlag.active?(:rate_limiting)
  Rails.application.config.middleware.use Rack::Throttle::Rules,
                                          rules: RackThrottleConfig::RULES,
                                          default: RackThrottleConfig::DEFAULT,
                                          code: 429,
                                          message: File.read(Rails.root.join('public/429.html')),
                                          type: 'text/html; charset=utf-8',
                                          cache: RackThrottleConfig.redis_url.present? ? Redis.new(url: RackThrottleConfig.redis_url) : {},
                                          key_prefix: :throttle
end
