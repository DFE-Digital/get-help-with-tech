require 'middleware/prevent_host_header_poisoning'

Rails.application.config.middleware.insert_before ActionDispatch::Executor,
                                                  Middleware::PreventHostHeaderPoisoning
