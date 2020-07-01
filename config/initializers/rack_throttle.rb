require 'rack/throttle'

class RackThrottleConfig
  RULES = [
    { method: "POST", limit: ENV.fetch('GHWT_MAX_POSTS_PER_SECOND', 4) },
    { method: "PUT", limit: ENV.fetch('GHWT_MAX_PUTS_PER_SECOND', 4) },
    { method: "PATCH", limit: ENV.fetch('GHWT_MAX_PATCHES_PER_SECOND', 4) },
    { method: "DELETE", limit: ENV.fetch('GHWT_MAX_DELETES_PER_SECOND', 4) },
    { method: "GET", limit: ENV.fetch('GHWT_MAX_GETS_PER_SECOND', 4) },
    { method: "GET", path: "/token/.*", limit: ENV.fetch('GHWT_MAX_TOKEN_GETS_PER_SECOND', 1) },
    { method: "GET", path: "/sign_in_tokens/.*", limit: ENV.fetch('GHWT_MAX_SIGN_IN_TOKENS_GETS_PER_SECOND', 1) },
  ]
  DEFAULT = 4
end

class Application < Rails::Application
  config.middleware.use Rack::Throttle::Rules,
                        rules: RackThrottleConfig::RULES,
                        default: RackThrottleConfig::DEFAULT
end
