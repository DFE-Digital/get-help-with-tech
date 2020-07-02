require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'rack/throttle'

module GovukRailsBoilerplate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.exceptions_app = routes

    # allow customisation of error messages at model level
    # see https://blog.bigbinary.com/2019/04/22/rails-6-allows-to-override-the-activemodel-errors-full_message-format-at-the-model-level-and-at-the-attribute-level.html
    config.active_model.i18n_customize_full_message = true


    # Ugly, having to define this here
    # It *was* in config/initializers/rack_throttle until that started to raise
    # a FreezeError when inserting the middleware, for some reason we haven't
    # fathomed yet (maybe a version bump in a dependency? actionpack-6.0.3.1?).
    # Defining it here in config/application.rb is what the docs advise anyway. 
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

    # We can't refer to FeatureFlag before the app is initialized
    if ENV['FEATURES_rate_limiting'] == 'active'
      config.middleware.use   Rack::Throttle::Rules,
                              rules: RackThrottleConfig::RULES,
                              default: RackThrottleConfig::DEFAULT
    end
  end
end
