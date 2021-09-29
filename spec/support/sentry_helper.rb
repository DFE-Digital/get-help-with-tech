module SentryHelper
  def stub_sentry_outgoing_api_calls(response_body: '', response_status: 200)
    stub_request(:post, 'https://sentry.io/api/1233849/envelope/')
      .to_return(status: response_status, body: response_body, headers: {})
  end
end

RSpec.configure do |c|
  c.include SentryHelper
end
