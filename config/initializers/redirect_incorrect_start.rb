require 'middleware/redirect_incorrect_start'

Rails.application.config.middleware.use Middleware::RedirectIncorrectStart
