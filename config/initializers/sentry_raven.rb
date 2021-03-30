Sentry.init do |config|
  config.dsn = Settings.sentry.dsn
  config.release = ENV['GIT_COMMIT_SHA']
end
