source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Canonical meta tag
gem 'canonical-rails'
gem 'dotenv-rails'
# Having Faker here rather than in dev/test lets us still create
# fake data in the deployed Docker container
gem 'faker'
# Manage multiple processes i.e. web server and webpack
gem 'foreman'
gem 'govuk_design_system_formbuilder'
gem 'haml'
gem 'http'

# GovUK Notify
gem 'mail-notify'

gem 'nokogiri'

# pagination
gem 'pagy'

# auditing of activerecord models
gem 'paper_trail'

# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# Pry console is more resilient to readline issues that can stop
# the arrow keys etc working
gem 'pry-rails'

# Use Puma as the app server
gem 'puma', '~> 4.3'

# Rate-limiting
gem 'rack-throttle'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 6.0.3.1'

# Used for markdown rendering of guidance pages
gem 'redcarpet'

# Error emails via Sentry
gem 'sentry-raven'

# Job queue
gem 'sidekiq'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Formalise config settings with support for env vars
gem 'config'

# Semantic Logger makes logs pretty, also needed for logit integration
gem 'rails_semantic_logger'

# GOV.UK Notify client
gem 'notifications-ruby-client'

# parsing XLSX spreadsheets for bulk extra data requests
gem 'rubyXL'

# Reusable view code
gem 'view_component'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.32'

  # Debugging
  gem 'pry-byebug'

  # Testing framework
  gem 'rspec-rails', '~> 4.0.1'

  # Stubbing web requests
  gem 'webmock'

  # GOV.UK interpretation of rubocop for linting Ruby
  gem 'rubocop-govuk'
  gem 'scss_lint-govuk'

  gem 'travis'

  # Allow testing logging to logstash in development
  gem 'logstash-logger', '~> 0.26.1'

  # PageObjects for tests
  gem 'site_prism'
end

group :development do
  # log failed I18n lookups
  gem 'i18n-debug'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.3'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # Gives a better error view with a web console
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'capybara-email'
  gem 'database_cleaner-active_record'
  gem 'fakeredis', require: 'fakeredis/rspec'
  gem 'timecop'
  gem 'webdrivers', '~> 4.3'
  gem 'shoulda-matchers', '~> 4.4'
end

group :development, :test do
  gem 'brakeman'
  gem 'bundle-audit'
  gem 'factory_bot_rails'
  gem 'simplecov'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
