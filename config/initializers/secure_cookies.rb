require 'middleware/secure_cookies'

Rails.application.config.middleware.insert_before ActionDispatch::Executor, Middleware::SecureCookies
