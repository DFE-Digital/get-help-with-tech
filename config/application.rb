require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"
require "govuk/components"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

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

    config.time_zone = 'London'

    # disable client-side XSS Auditors, as they have been removed from most
    # modern browsers because they can cause additional vulnerabilities
    # (see https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html#x-xss-protection-header)
    config.action_dispatch.default_headers['X-XSS-Protection'] = '0'

    config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
    config.view_component.preview_controller = "ComponentPreviewController"
    config.view_component.show_previews = (ENV['FEATURES_show_component_previews'] == 'active')
  end
end
