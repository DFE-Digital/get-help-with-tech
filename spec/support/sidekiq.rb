ActiveJob::Base.queue_adapter = :test

require 'sidekiq/testing'
Sidekiq::Testing.inline!
