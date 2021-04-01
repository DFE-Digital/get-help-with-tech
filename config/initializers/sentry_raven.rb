Sentry.init do |config|
  config.dsn = Settings.sentry.dsn
  config.release = ENV['GIT_COMMIT_SHA']
  config.traces_sample_rate = 0.2
  config.environment = ENV['SERVICE_ENV'] || 'development'
end
