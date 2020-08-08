require 'sidekiq/testing'
ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  include ActiveJob::TestHelper

  # Turn Sidekiq on automatically in feature specs. Use `sidekiq: false` in
  # tests to avoid Sidekiq running.
  config.define_derived_metadata(file_path: Regexp.new('/spec/features/')) do |metadata|
    metadata[:sidekiq] = true unless metadata[:sidekiq] == false
  end

  # Use `sidekiq: true` to run jobs immediately
  config.around sidekiq: true do |example|
    perform_enqueued_jobs do
      Sidekiq::Testing.inline! do
        example.run
      end
    end
  end
end
