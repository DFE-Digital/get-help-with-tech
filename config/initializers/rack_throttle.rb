require 'rack/throttle'
require_relative '../../app/services/feature_flag'

class RackThrottleConfig
  RULES = [
    { method: 'POST', limit: Integer(ENV.fetch('GHWT_MAX_POSTS_PER_SECOND', 4)) },
    { method: 'PUT', limit: Integer(ENV.fetch('GHWT_MAX_PUTS_PER_SECOND', 4)) },
    { method: 'PATCH', limit: Integer(ENV.fetch('GHWT_MAX_PATCHES_PER_SECOND', 4)) },
    { method: 'DELETE', limit: Integer(ENV.fetch('GHWT_MAX_DELETES_PER_SECOND', 4)) },
    { method: 'GET', limit: Integer(ENV.fetch('GHWT_MAX_GETS_PER_SECOND', 4)) },
    { method: 'GET', path: '/token/.*', limit: Integer(ENV.fetch('GHWT_MAX_TOKEN_GETS_PER_SECOND', 1)) },
    { method: 'GET', path: '/sign_in_tokens/.*', limit: Integer(ENV.fetch('GHWT_MAX_TOKEN_GETS_PER_SECOND', 1)) },
  ].freeze
  DEFAULT = 4
end

# only do this if enabled, so that we don't throttle features specs, for instance
if FeatureFlag.active?(:rate_limiting)
  Rails.application.config.middleware.use Rack::Throttle::Rules,
                                          rules: RackThrottleConfig::RULES,
                                          default: RackThrottleConfig::DEFAULT,
                                          code: 429
end
