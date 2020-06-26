require 'middleware/secure_cookies'

Rails.application.config.middleware.insert_after ActionDispatch::Cookies, Middleware::SecureCookies
