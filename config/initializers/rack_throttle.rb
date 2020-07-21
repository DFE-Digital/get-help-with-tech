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
    { method: 'GET', path: '/sign_in_tokens/.*', limit: Integer(Settings.throttling.limits['/sign_in_tokens'].get) },
  ].freeze
  DEFAULT = Settings.throttling.default_limit
end

# only do this if enabled, so that we don't throttle features specs, for instance
if FeatureFlag.active?(:rate_limiting)
  Rails.application.config.middleware.use Rack::Throttle::Rules,
                                          rules: RackThrottleConfig::RULES,
                                          default: RackThrottleConfig::DEFAULT,
                                          code: 429,
                                          message: File.read(File.join(Rails.root, 'public', '429.html')),
                                          type: 'text/html; charset=utf-8'
end
